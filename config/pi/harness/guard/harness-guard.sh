#!/usr/bin/env bash
# harness-guard.sh — end-of-session sensor enforcement for the agent harness.
#
# Modes:
#   harness-guard.sh            generic/pi mode: remediation on stdout, exit 1 when stale
#   harness-guard.sh --claude   Claude Stop hook mode: reads hook JSON on stdin,
#                               remediation on stderr, exit 2 when stale
#   harness-guard.sh --stamp    print "SRC-FT <newest-src-mtime>" on stdout; the
#                               implementer appends this line to sensor-log.md at
#                               each checkpoint
#   harness-guard.sh --abandon  disarm an active run: delete .harness/active and
#                               the guard state, exit 0
#
# Exit 0 = allow finish (no active run | log fresh | block budget exhausted).
# Non-zero = stale: source files are newer than the sensor log.
#
# Freshness check: if sensor-log.md contains SRC-FT lines (written via --stamp at
# each checkpoint), the newest stamp must be >= the current source fingerprint.
# A stamp shows that content was appended through the guard after the sources
# last changed — a bare `touch` of the log does not pass. Stamps deter
# accidental staleness; they are NOT forgery-proof (a hand-written future stamp
# passes). Honesty is enforced by the code reviewer's diff/log cross-check.
# Logs without any stamp fall back to plain mtime comparison (legacy/human-
# written logs).
#
# Source fingerprint: newest mtime among git-tracked AND untracked, non-ignored
# files (untracked files are sources too), excluding .harness/ artifacts.
# Known limitation: deleting a file moves no mtime; the code reviewer catches
# deletions in the diff.
#
# State files (in the project repo root):
#   .harness/active         single line: absolute path of the active feature dir
#   .harness/.guard-state   "<newest-src-mtime> <consecutive-block-count>"
#
# Portability: Linux (stat -c) and macOS (stat -f), bash 3.2+. Requires git.

set -euo pipefail

MODE="${1:-}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

# stat flavor detection (GNU vs BSD), done once.
if stat -c '%Y' . >/dev/null 2>&1; then
	STAT_FMT=(stat -c %Y)
else
	STAT_FMT=(stat -f %m)
fi

# Newest mtime among git-tracked + untracked non-ignored files, excluding
# .harness/ artifacts. Batched: one stat call for the whole list instead of
# one fork per file. Prints nothing when there are no candidate files.
newest_src_mtime() {
	local -a files=()
	local f
	while IFS= read -r -d '' f; do
		case "$f" in .harness/*) continue ;; esac
		[ -e "$f" ] || continue # tracked but deleted
		files+=("$f")
	done < <(git ls-files -z -c -o --exclude-standard 2>/dev/null || true)
	[ "${#files[@]}" -eq 0 ] && return 0
	# `|| true`: a file vanishing mid-run must not kill the guard (set -e/pipefail).
	# printf+xargs chunking keeps argv under ARG_MAX (E2BIG) on huge repos.
	printf '%s\0' "${files[@]}" | xargs -0 -n 1000 "${STAT_FMT[@]}" 2>/dev/null |
		awk '$1 > m { m = $1 } END { if (m > 0) print m }' || true
}

mtime() { stat -c '%Y' "$1" 2>/dev/null || stat -f '%m' "$1" 2>/dev/null || echo 0; }

# --- utility modes -----------------------------------------------------------

if [ "$MODE" = "--stamp" ]; then
	SRC_MTIME="$(newest_src_mtime)"
	[ -n "$SRC_MTIME" ] && echo "SRC-FT $SRC_MTIME"
	exit 0
fi

if [ "$MODE" = "--abandon" ]; then
	rm -f .harness/active .harness/.guard-state
	echo "harness run disarmed (.harness/active removed)"
	exit 0
fi

# --- enforcement mode --------------------------------------------------------

ACTIVE_FILE=".harness/active"

# No active harness run → never interfere with normal sessions.
[ -f "$ACTIVE_FILE" ] || exit 0

# Preserve interior whitespace (paths may contain spaces); strip a
# trailing CR for CRLF-written markers.
IFS= read -r FEATURE_DIR <"$ACTIVE_FILE" || true
FEATURE_DIR="${FEATURE_DIR%$'\r'}"

# Active marker is empty or points at a vanished run → treat as abandoned:
# disarm instead of blocking every session forever.
if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
	rm -f "$ACTIVE_FILE" .harness/.guard-state
	exit 0
fi

LOG="$FEATURE_DIR/sensor-log.md"

SRC_MTIME="$(newest_src_mtime)"
[ -z "$SRC_MTIME" ] && exit 0 # no source files → nothing to enforce

STALE=0
if [ ! -f "$LOG" ]; then
	STALE=1
else
	# Last stamp wins; empty when the log has no stamps. Non-numeric
	# garbage (e.g. a pasted "SRC-FT <mtime>" placeholder) is discarded
	# and falls through to the legacy mtime path.
	STAMP="$(awk '$1 == "SRC-FT" { v = $2 } END { if (v != "") print v }' "$LOG")"
	case "$STAMP" in *[!0-9]*) STAMP="" ;; esac
	if [ -n "$STAMP" ]; then
		[ "$SRC_MTIME" -gt "$STAMP" ] && STALE=1
	else
		# Legacy logs without stamps: mtime comparison.
		[ "$SRC_MTIME" -gt "$(mtime "$LOG")" ] && STALE=1
	fi
fi

if [ "$STALE" -eq 0 ]; then
	rm -f .harness/.guard-state
	exit 0
fi

# Loop prevention: same source mtime across blocks → increment counter;
# after 3 consecutive blocks with no new edits, allow the stop through
# (the human sees the unfinished state in the report / session) rather
# than trapping the agent forever.
STATE_FILE=".harness/.guard-state"
LAST_MTIME=0
BLOCKS=0
if [ -f "$STATE_FILE" ]; then
	read -r LAST_MTIME BLOCKS <"$STATE_FILE" || true
fi
if [ "$SRC_MTIME" -le "$LAST_MTIME" ]; then
	BLOCKS=$((BLOCKS + 1))
else
	BLOCKS=1
fi
echo "$SRC_MTIME $BLOCKS" >"$STATE_FILE"
if [ "$BLOCKS" -ge 3 ]; then
	rm -f "$STATE_FILE"
	exit 0
fi

MSG="$(cat <<-EOF
	SENSOR GATE: finish blocked — source files are newer than the sensor log.
	Active harness run: $FEATURE_DIR
	Before finishing, do ONE of:
	  1. Run the declared sensors (typecheck → lint → test, per project AGENTS.md),
	     then append each command + result to: $LOG
	     End the entry with a source-fingerprint stamp line:
	       bash "$0" --stamp >> "$LOG"
	  2. If the implementation is complete: run the full gauntlet sweep (coverage,
	     mutation, review), write report.md. On a GREEN verdict delete
	     .harness/active; on RED leave it armed (or: bash "$0" --abandon)
	  3. If this run was abandoned by the human:
	       bash "$0" --abandon
	EOF
)"

if [ "$MODE" = "--claude" ]; then
	cat >/dev/null 2>&1 || true # drain hook JSON from stdin
	echo "$MSG" >&2
	exit 2
else
	echo "$MSG"
	exit 1
fi
