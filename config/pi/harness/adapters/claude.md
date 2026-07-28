# Adapter: Claude Code

## Install (per project or user-level)

1. Copy the skill bodies into commands:
   - `skills/harness-spec/SKILL.md` → `.claude/commands/harness-spec.md`
   - `skills/harness-gauntlet/SKILL.md` → `.claude/commands/harness-gauntlet.md`
     Keep the prompt references valid by copying the `harness/` directory next
     to them (e.g. `.claude/harness/`) and rewriting `../../harness/` paths to
     match, or reference an absolute checkout of this repo.
2. Merge `claude-settings.snippet.json` into `.claude/settings.json`
   (project) or `~/.claude/settings.json` (user), adjusting the command path
   to where `harness-guard.sh` lives.

## Spawning a fresh-context reviewer

Where the pi adapter says "subagent tool with context fresh", use the **Task
tool** with a clear instruction that the subagent must judge the artifacts
cold. The Task tool's subagent has no access to the parent conversation —
that is the context isolation.

## End-of-session guard

The Stop hook runs `harness-guard.sh --claude`. When stale, the script
exits 2 and its stderr is fed back to Claude as the reason it cannot stop.
Loop prevention is built into the script (3-block budget).

The implementer appends `harness-guard.sh --stamp` output to sensor-log.md
at each checkpoint; the human can disarm a dropped run with
`harness-guard.sh --abandon`.
