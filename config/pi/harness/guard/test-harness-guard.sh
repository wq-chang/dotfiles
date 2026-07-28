#!/usr/bin/env bash
# Fixture-based tests for harness-guard.sh. Run: bash test-harness-guard.sh
set -uo pipefail

GUARD="$(cd "$(dirname "$0")" && pwd)/harness-guard.sh"
PASS=0
FAIL=0

# Portable past/future mtimes (touch -t is POSIX; -d is GNU-only).
PAST=202001010000.00
FUTURE=203801010000.00

# --- temp dir cleanup --------------------------------------------------------
TMPDIRS=()
cleanup() { [ "${#TMPDIRS[@]}" -gt 0 ] && rm -rf "${TMPDIRS[@]}"; }
trap cleanup EXIT

ok() {
	PASS=$((PASS + 1))
	echo "ok   - $1"
}
bad() {
	FAIL=$((FAIL + 1))
	echo "FAIL - $1"
}
check() { # name expected actual
	if [ "$2" -eq "$3" ]; then ok "$1"; else bad "$1 (expected exit $2, got $3)"; fi
}

setup_repo() {
	local dir
	dir="$(mktemp -d)"
	TMPDIRS+=("$dir")
	git -C "$dir" init -q
	git -C "$dir" config user.email test@test
	git -C "$dir" config user.name test
	echo "console.log('x')" >"$dir/app.ts"
	git -C "$dir" add app.ts
	git -C "$dir" commit -qm init
	echo "$dir"
}

setup_repo_proj() { # name — create a repo dir with spaces in the path
	local dir name="$1"
	dir="$(mktemp -d)/$name"
	mkdir -p "$dir"
	TMPDIRS+=("$(dirname "$dir")") # cleanup the parent
	git -C "$dir" init -q
	git -C "$dir" config user.email test@test
	git -C "$dir" config user.name test
	echo "console.log('x')" >"$dir/app.ts"
	git -C "$dir" add app.ts
	git -C "$dir" commit -qm init
	echo "$dir"
}

activate() { # repo — create .harness/active pointing at feature dir with a stale log
	mkdir -p "$1/.harness/feat-x"
	echo "# sensor log" >"$1/.harness/feat-x/sensor-log.md"
	touch -t "$PAST" "$1/.harness/feat-x/sensor-log.md"
	echo "$1/.harness/feat-x" >"$1/.harness/active"
}

# 1. No active marker → exit 0 (never interfere with normal sessions)
R=$(setup_repo)
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "no active marker exits 0" 0 $?

# 2. Active run + fresh log (legacy mtime path) → exit 0
R=$(setup_repo)
mkdir -p "$R/.harness/feat-x"
echo "# sensor log" >"$R/.harness/feat-x/sensor-log.md"
touch -t "$FUTURE" "$R/.harness/feat-x/sensor-log.md"
echo "$R/.harness/feat-x" >"$R/.harness/active"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "fresh log exits 0" 0 $?

# 3. Active run + source newer than log → exit 1 + SENSOR GATE message on stdout
R=$(setup_repo)
activate "$R"
echo "// change" >>"$R/app.ts"
git -C "$R" add app.ts && git -C "$R" commit -qm change
OUT="$(cd "$R" && "$GUARD")"
RC=$?
check "stale exits 1" 1 $RC
echo "$OUT" | grep -q "SENSOR GATE" && ok "stdout contains SENSOR GATE" || bad "stdout contains SENSOR GATE"

# 4. Active run + missing sensor log → exit 1
R=$(setup_repo)
mkdir -p "$R/.harness/feat-x"
echo "$R/.harness/feat-x" >"$R/.harness/active"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "missing log exits 1" 1 $?

# 5. Claude mode → exit 2 + SENSOR GATE message on stderr, stdin drained
R=$(setup_repo)
activate "$R"
echo "// change" >>"$R/app.ts"
git -C "$R" add app.ts && git -C "$R" commit -qm change
ERR="$(cd "$R" && echo '{"stop_hook_active":false}' | "$GUARD" --claude 2>&1 >/dev/null)"
RC=$?
check "claude stale exits 2" 2 $RC
echo "$ERR" | grep -q "SENSOR GATE" && ok "stderr contains SENSOR GATE" || bad "stderr contains SENSOR GATE"

# 6. Loop prevention: 3rd consecutive block with unchanged sources → exit 0
R=$(setup_repo)
activate "$R"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
B1=$?
(cd "$R" && "$GUARD" >/dev/null 2>&1)
B2=$?
(cd "$R" && "$GUARD" >/dev/null 2>&1)
B3=$?
check "block 1 exits 1" 1 $B1
check "block 2 exits 1" 1 $B2
check "block 3 allows stop (exit 0)" 0 $B3

# 7. Guard state resets when log becomes fresh again
R=$(setup_repo)
activate "$R"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
touch -t "$FUTURE" "$R/.harness/feat-x/sensor-log.md"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "fresh log after block exits 0" 0 $?
[ ! -f "$R/.harness/.guard-state" ] && ok "fresh log removes guard state" || bad "fresh log removes guard state"

# 8. Untracked new source file counts as a source change → exit 1
R=$(setup_repo)
activate "$R"
echo "console.log('new')" >"$R/new-file.ts" # untracked, newer than the log
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "untracked newer file exits 1" 1 $?

# 9. Stamped log passes even when log mtime is older than sources
R=$(setup_repo)
activate "$R"
(cd "$R" && "$GUARD" --stamp >>"$R/.harness/feat-x/sensor-log.md")
touch -t "$PAST" "$R/.harness/feat-x/sensor-log.md" # mtime stale, content fresh
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "stamped log with old mtime exits 0" 0 $?

# 9b. Garbage stamp (e.g. pasted placeholder) falls back to legacy mtime path → stale
R=$(setup_repo)
activate "$R"
echo "SRC-FT <mtime>" >>"$R/.harness/feat-x/sensor-log.md"
touch -t "$PAST" "$R/.harness/feat-x/sensor-log.md"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "garbage stamp exits 1 (legacy fallback)" 1 $?

# 9c. Garbage stamp on an otherwise-fresh log does not break the fresh path
R=$(setup_repo)
activate "$R"
echo "SRC-FT <mtime>" >>"$R/.harness/feat-x/sensor-log.md"
touch -t "$FUTURE" "$R/.harness/feat-x/sensor-log.md"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "garbage stamp + fresh mtime exits 0" 0 $?

# 10. Stale stamp (sources changed after the checkpoint) → exit 1
R=$(setup_repo)
activate "$R"
(cd "$R" && "$GUARD" --stamp >>"$R/.harness/feat-x/sensor-log.md")
sleep 1
echo "// change" >>"$R/app.ts"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "source newer than stamp exits 1" 1 $?

# 11. --stamp prints a SRC-FT fingerprint line
R=$(setup_repo)
OUT="$(cd "$R" && "$GUARD" --stamp)"
RC=$?
check "--stamp exits 0" 0 $RC
echo "$OUT" | grep -qE '^SRC-FT [0-9]+$' && ok "--stamp prints SRC-FT line" || bad "--stamp prints SRC-FT line (got: $OUT)"

# 12. --abandon disarms the run
R=$(setup_repo)
activate "$R"
(cd "$R" && "$GUARD" --abandon >/dev/null 2>&1)
RC=$?
check "--abandon exits 0" 0 $RC
[ ! -f "$R/.harness/active" ] && ok "--abandon removes active marker" || bad "--abandon removes active marker"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "guard passes after --abandon" 0 $?

# 13. Active marker pointing at a vanished feature dir → disarm + exit 0
R=$(setup_repo)
mkdir -p "$R/.harness"
echo "$R/.harness/gone" >"$R/.harness/active"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "missing feature dir exits 0" 0 $?
[ ! -f "$R/.harness/active" ] && ok "missing feature dir removes active marker" || bad "missing feature dir removes active marker"

# 14. Blocks counter resets when sources change between guard calls
R=$(setup_repo)
activate "$R"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "block 1 exits 1" 1 $?
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "block 2 exits 1" 1 $?
# edit source = new mtime → counter should reset
sleep 1
echo "// change" >>"$R/app.ts"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "after source change exits 1 (reset to block 1)" 1 $?
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "block 2 again exits 1" 1 $?
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "block 3 allows stop (exit 0)" 0 $?

# 15. Repo with spaces in path — active marker works
R="$(setup_repo_proj 'my project')"
activate "$R"
echo "// change" >>"$R/app.ts"
git -C "$R" add app.ts && git -C "$R" commit -qm change
OUT="$(cd "$R" && "$GUARD")"
RC=$?
check "space-in-path stale exits 1" 1 $RC
echo "$OUT" | grep -q "SENSOR GATE" && ok "space-in-path remediation shows" || bad "space-in-path remediation shows"

# 16. Empty repo (no candidate source files) + active run → exit 0
R=$(setup_repo)
rm "$R/app.ts"
git -C "$R" rm -q app.ts && git -C "$R" commit -qm empty
mkdir -p "$R/.harness/feat-x"
echo "# log" >"$R/.harness/feat-x/sensor-log.md"
echo "$R/.harness/feat-x" >"$R/.harness/active"
(cd "$R" && "$GUARD" >/dev/null 2>&1)
check "empty repo exits 0" 0 $?

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
