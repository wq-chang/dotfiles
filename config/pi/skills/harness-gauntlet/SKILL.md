---
name: harness-gauntlet
description: "Implement an approved spec+plan through the constraint gauntlet: TDD with sensor checkpoints, acceptance tests, mutation testing, and independent code review. Ends with a GREEN/RED report. Use only after the human has approved spec.md and plan.md."
---

# Harness: The Gauntlet

Automates implementation of a human-approved spec+plan. The human reads only
the final report.md — GREEN means merge without reading code.

Prompt files referenced below resolve relative to this skill directory:
`../../harness/prompts/<file>.md`. Subagent spawning: follow
`../../harness/adapters/pi.md` (or the adapter matching the current CLI).
Any path beginning `../../harness/` in this file or the prompts it
references resolves against this skill directory — substitute the
absolute path on disk when executing commands.

## Preconditions (verify, else stop)

- `.harness/<slug>/spec.md` and `plan.md` exist and the human has said
  "approved" (or equivalent) in this session.
- Project AGENTS.md (or harness.yaml) declares sensors (format:
  `../../harness/sensors.md`). Missing keys are legal — run what exists,
  list gaps in report.md.

## Flow

1. **Arm the guard** — write the absolute path of `.harness/<slug>` into
   `.harness/active`. From now on an end-of-session guard blocks finishing
   while sources are newer than sensor-log.md. Only one run can be active at
   a time — arming overwrites any previous marker. Also record the review
   base: `git rev-parse HEAD` → `.harness/<slug>/base`.
2. **Implement** — read `../../harness/prompts/implementer.md` and follow it:
   task-by-task TDD with mandatory sensor checkpoints logged to
   `.harness/<slug>/sensor-log.md`.
3. **Acceptance tests** — at each slice boundary, read
   `../../harness/prompts/acceptance-test-writer.md` and follow it for the
   slice's ACs.
4. **Final sweep** — coverage vs threshold; mutation testing (incremental,
   changed files only) vs `mutation_score_min`; any other declared sensors.
   Mutation survivors that matter → strengthen tests, re-run (max 2 rounds).
   Log everything.
5. **Independent review** — run `git add -A` first (stages new files so
   they appear in the diff; does not commit), then spawn a fresh-context
   subagent (per adapter):
   "Read `../../harness/prompts/code-reviewer.md` and follow it. Spec:
   .harness/<slug>/spec.md. Plan: .harness/<slug>/plan.md. Diff: git diff
   $(cat .harness/<slug>/base)  (base → working tree, covers committed AND
   uncommitted work). Sensor log: .harness/<slug>/sensor-log.md. AC→AT map:
   .harness/<slug>/at-map.md." For rounds ≥2, append: "Prior review rounds:
   .harness/<slug>/code-review.md — mark each finding NEW or REPEAT."
   Append its full output to `.harness/<slug>/code-review.md` under a
   `## Round N` heading.
6. **Fix loop** — VERDICT: REJECT → fix findings as new tasks (with sensor
   checkpoints), re-review. Convergence escape: if a round's blocker findings
   are all REPEATs (the same issues surviving a fix attempt), stop looping
   and report RED with the unresolved findings — the human breaks the tie.
   Hard cap: 3 rounds, then report RED with unresolved findings.
7. **Report + disarm** — write `.harness/<slug>/report.md`: verdict line
   (GREEN/RED), AC→AT mapping table (from at-map.md), sensor summary
   (coverage %, mutation score, thresholds), findings (if any),
   declared-but-missing sensors, and any "Notes for human" entries from
   sensor-log.md. Only a GREEN verdict deletes
   `.harness/active`; on RED, leave it, tell the human exactly what to look
   at, and note that `bash ../../harness/guard/harness-guard.sh --abandon`
   disarms the run once they decide to drop it.
