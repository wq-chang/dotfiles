# Harness Flow

Two-phase workflow for autonomous AI-driven feature development with mandatory
sensor enforcement and independent review.

---

## Phase 1: Spec & Plan (`harness-spec`)

Generates a reviewed spec + TDD plan. Does NOT implement anything.
Stops at the human approval gate.

```
HUMAN describes intent
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 0. GRILL (optional)  —  if intent is vague        │
  │    Interview user one question at a time until    │
  │    shared understanding. Facts from codebase,     │
  │    decisions from human.                          │
  │    Output: crisp unambiguous intent.              │
  └─────┬─────────────────────────────────────────────┘
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 1. SLUG  —  create .harness/<slug>/               │
  └─────┬─────────────────────────────────────────────┘
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 2. SPEC  —  spec-writer.md                        │
  │    Problem statement, Goals, Non-goals,           │
  │    Acceptance criteria (Given/When/Then),         │
  │    Scope boundary, Open questions                 │
  └─────┬─────────────────────────────────────────────┘
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 3. PLAN  —  plan-writer.md                        │
  │    Architecture, ordered TDD tasks in slices,     │
  │    AC coverage table, sensor checkpoint contract  │
  │    Reads project's sensor declarations first      │
  │    (AGENTS.md or harness.yaml)                    │
  └─────┬─────────────────────────────────────────────┘
        │
  ┌─────▼──────────────────────────────────────────────┐
  │ 4. INDEPENDENT REVIEW  —  fresh-context subagent   │
  │    spec-reviewer.md                                │
  │    Checks: feasibility grounding, intent alignment,│
  │    scope discipline, AC quality, plan coverage,    │
  │    contradictions                                  │
  │    Output → review.md  (## Round N)                │
  └─────┬──────────────────────────────────────────────┘
        │
  ┌─────▼──────────────────┐         REJECT
  │ 5. LOOP                │───────► revise spec/plan ─┐
  │    PASS?               │◄──────────────────────────┘
  │    All-REPEAT escape?  │───────► stop (tie → human)
  │    Max 3 rounds        │───────► keep findings visible
  └─────┬──────────────────┘
        │ PASS (or rounds exhausted)
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 6. HUMAN GATE  (hard stop)                        │
  │    Present: spec.md, plan.md, review.md           │
  │    "Say 'approved' to unlock the gauntlet."       │
  └──────────────────────┬────────────────────────────┘
                         │ HUMAN: "approved"
                         ▼
```

---

## Phase 2: Gauntlet (`harness-gauntlet`)

Implements a human-approved spec+plan through a constraint gauntlet.
The human reads only the final `report.md` — GREEN means merge without reading code.

```
HUMAN: "approved"
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 1. ARM GUARD                                      │
  │    Write .harness/active  ← <absolute feature dir>│
  │    Record git base  → .harness/<slug>/base        │
  │    (overwrites any previous active marker)        │
  └─────┬─────────────────────────────────────────────┘
        │
  ┌─────▼────────────────────────────────────────────────┐
  │ 2. IMPLEMENT  (implementer.md)                       │
  │                                                      │
  │  ┌─ PER TASK ──────────────────────────────────────┐ │
  │  │  RED    → write failing test                    │ │
  │  │  GREEN  → minimal implementation                │ │
  │  │  REFACTOR → within task scope only              │ │
  │  │                                                 │ │
  │  │  SENSOR CHECKPOINT (mandatory, logged):         │ │
  │  │    a. Read sensor block (AGENTS.md/harness.yaml)│ │
  │  │    b. Run: typecheck → lint → test              │ │
  │  │    c. Failure → fix, re-run (≤3 self-correct)   │ │
  │  │    d. Append to sensor-log.md:                  │ │
  │  │       timestamp, task, commands, exit codes     │ │
  │  │    e. Append SRC-FT stamp (guard --stamp)       │ │
  │  │    f. Append to .harness/<slug>/progress:       │ │
  │  │       DONE <N> <name> <ISO-8601 timestamp>      │ │
  │  │                                                 │ │
  │  │  No new dependencies. Unplanned ideas →         │ │
  │  │  "Notes for human" in sensor-log, never code.   │ │
  │  │  Never weaken/delete/skip a failing test.       │ │
  │  └─────────────────────────────────────────────────┘ │
  │                                                      │
  │  ┌─ SLICE BOUNDARY ──────────────────────────────┐   │
  │  │  Coverage vs threshold; add tests if below    │   │
  │  │  Hand ACs → acceptance-test stage             │   │
  │  │  Update at-map.md (FAIL→PASS as ATs pass)     │   │
  │  └───────────────────────────────────────────────┘   │
  │                                                      │
  │  Resume: skip DONE tasks in .harness/<slug>/progress.│
  │  If last DONE task's log entry is missing, redo      │
  │  from RED (code may exist, never validated).         │
  └─────┬────────────────────────────────────────────────┘
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 3. ACCEPTANCE TESTS  (per slice boundary)         │
  │    acceptance-test-writer.md                      │
  │    Writes tests tagged AC<n>                      │
  │    Creates .harness/<slug>/at-map.md              │
  │    At re-run, updates ALL statuses                │
  │    Appends one-line pointer to sensor-log.md      │
  └─────┬─────────────────────────────────────────────┘
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 4. FINAL SWEEP                                    │
  │    Coverage vs threshold                          │
  │    Mutation testing (incremental, changed files)  │
  │    vs mutation_score_min                          │
  │    Survivors → strengthen tests, re-run (≤2 rds)  │
  │    Any other declared sensors                     │
  │    Log everything                                 │
  └─────┬─────────────────────────────────────────────┘
        │
  ┌─────▼───────────────────────────────────────────────┐
  │ 5. INDEPENDENT CODE REVIEW  (fresh-context subagent │
  │    git add -A -- . ':!.harness/'  (stage, no commit)│
  │    code-reviewer.md                                 │
  │    Checks: sensor-log integrity (declared sensors   │
  │    only), AC↔AT traceability (from at-map.md),      │
  │    assertion quality, spec fidelity, plan discipline│
  │    Output → code-review.md (## Round N)             │
  └─────┬───────────────────────────────────────────────┘
        │
  ┌─────▼──────────────────┐         REJECT
  │ 6. FIX LOOP            │───────► fix + re-review ──┐
  │    GREEN?              │◄──────────────────────────┘
  │    All-REPEAT escape?  │───────► RED early (tie → human)
  │    Max 3 rounds        │───────► RED with findings
  └─────┬──────────────────┘
        │
  ┌─────▼─────────────────────────────────────────────┐
  │ 7. REPORT  (.harness/<slug>/report.md)            │
  │                                                   │
  │    VERDICT: GREEN or RED                          │
  │    AC→AT mapping table (from at-map.md)           │
  │    Sensor summary (coverage %, mutation score,    │
  │      thresholds)                                  │
  │    Findings (if any)                              │
  │    Declared-but-missing sensors                   │
  │    "Notes for human" from sensor-log.md           │
  │                                                   │
  │    GREEN: delete .harness/active                  │
  │           git reset HEAD -- .harness/             │
  │           git commit (implementation only)        │
  │    RED:   leave .harness/active (guard stays)     │
  │           leave uncommitted                       │
  │           tell human + abandon command            │
  └───────────────────────────────────────────────────┘
```

---

## Guard Enforcement

Runs at every session end via pi extension `agent_end` hook
(or Claude Stop hook in `--claude` mode).

```
session end
        │
        ▼
harness-guard.sh
        │
  ┌─────▼──────────────────────────┐
  │ .harness/active missing?      │──yes──► exit 0  (nothing to enforce)
  └─────┬──────────────────────────┘
        │ no
  ┌─────▼──────────────────────────┐
  │ Feature dir vanished?          │──yes──► auto-disarm, exit 0
  └─────┬──────────────────────────┘
        │ no
  ┌─────▼──────────────────────────┐
  │ Fast-path: stamp ≥ last commit │──yes──► exit 0  (fresh)
  │ AND tree clean (outside        │
  │ .harness/)?                    │
  └─────┬──────────────────────────┘
        │ no
  ┌─────▼──────────────────────────┐
  │ Log has SRC-FT stamps?        │
  └─────┬──────────────────────────┘
        │ yes                    no (legacy)
  ┌─────▼──────────┐    ┌─────────▼──────────────┐
  │ src_mtime >    │    │ src_mtime > log mtime? │
  │ newest stamp?  │    └─────────┬──────────────┘
  └─────┬──────────┘              │
    yes │     no             yes  │  no
    ┌───▼──┐ ┌──▼──┐       ┌─────▼───┐ ┌──▼──┐
    │STALE │ │FRESH│       │ STALE   │ │FRESH│
    └──┬───┘ └──┬──┘       └────┬────┘ └──┬──┘
       │        │               │         │
       │        │               │         │
       │   ┌────▼────┐          │    ┌────▼────┐
       │   │rm state │          │    │rm state │
       │   │exit 0   │          │    │exit 0   │
       │   └─────────┘          │    └─────────┘
       │                        │
  ┌────▼────────────────────────▼────┐
  │ Loop prevention:                 │
  │   same src_mtime → increment     │
  │   blocks in .guard-state;        │
  │   ≥3 blocks → give up, exit 0    │
  │                                  │
  │ Otherwise: remediation message   │
  │   pi mode:  stdout, exit 1       │
  │   claude:   stderr, exit 2       │
  └──────────────────────────────────┘
```

### Remediation message

When the guard blocks, it tells the agent to do ONE of:

1. Run declared sensors → append results + SRC-FT stamp to `sensor-log.md`
2. Complete the gauntlet sweep → write `report.md`
   - GREEN: delete `.harness/active`
   - RED: leave it armed (or run `guard --abandon`)
3. Abandon the run → `guard --abandon` (deletes `.harness/active`)

### Guard modes

| Mode        | Trigger                    | Behavior                                                  |
| ----------- | -------------------------- | --------------------------------------------------------- |
| (default)   | pi extension `agent_end`   | Remediation on stdout, exit 1                             |
| `--claude`  | Claude Stop hook           | Reads hook JSON from stdin, remediation on stderr, exit 2 |
| `--stamp`   | Implementer at checkpoints | Prints `SRC-FT <newest-src-mtime>` on stdout              |
| `--abandon` | Human drops a run          | Deletes `.harness/active` + `.harness/.guard-state`       |

---

## Artifacts

| File                             | Writer                   | Reader(s)                                    | When                                            |
| -------------------------------- | ------------------------ | -------------------------------------------- | ----------------------------------------------- |
| `.harness/<slug>/spec.md`        | spec-writer              | plan-writer, reviewers, human gate           | Phase 1, frozen at gate                         |
| `.harness/<slug>/plan.md`        | plan-writer              | implementer, reviewers, human gate           | Phase 1, frozen at gate                         |
| `.harness/<slug>/review.md`      | spec-reviewer (subagent) | loop rounds, human gate                      | Appended per review round                       |
| `.harness/active`                | gauntlet step 1          | guard, human                                 | Armed at start, deleted on GREEN or `--abandon` |
| `.harness/.guard-state`          | guard (auto)             | guard (auto)                                 | Loop-prevention counter, cleared on fresh       |
| `.harness/<slug>/base`           | gauntlet step 1          | gauntlet step 5                              | Recorded at arm, read for `git diff`            |
| `.harness/<slug>/sensor-log.md`  | implementer              | guard, code-reviewer                         | Appended per checkpoint with SRC-FT stamps      |
| `.harness/<slug>/progress`       | implementer              | gauntlet (resume)                            | Appended per task: `DONE N name ISO-8601`       |
| `.harness/<slug>/at-map.md`      | acceptance-test-writer   | implementer (updates), code-reviewer, report | Created on first slice boundary                 |
| `.harness/<slug>/code-review.md` | code-reviewer (subagent) | fix loop, report                             | Appended per review round                       |
| `.harness/<slug>/report.md`      | gauntlet step 7          | **human**                                    | Written once at end; GREEN/RED verdict          |

---

## Path Resolution Rule

Both skills declare:

> Any path beginning `../../harness/` in the skill file or its prompts resolves
> against this skill directory. Before spawning any subagent or writing any
> human-facing output (report.md, messages), resolve ALL `../../harness/`
> references to absolute paths. The subagent has no knowledge of this skill's
> directory; the human can't resolve relative paths either.

---

## Sensor Declarations

A project declares sensors in one of two places (AGENTS.md wins if both exist):

**AGENTS.md:**

```markdown
## Sensors

- typecheck: npx tsc --noEmit
- lint: npx eslint .
- test: npm test
- coverage: npm run coverage # optional
- coverage_threshold: 80 # optional
- mutation: npx stryker run # optional
- mutation_score_min: 65 # optional
```

**harness.yaml:**

```yaml
sensors:
  typecheck: npx tsc --noEmit
  lint: npx eslint .
  test: npm test
```

Missing keys are legal — the implementer runs what exists and lists gaps in `report.md`.
Commands must already exist in the project; the harness never adds tooling.

---

## Key Design Decisions

| Decision                                     | Rationale                                                                                  |
| -------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Fresh-context independent review             | Reviewer sees artifacts cold; no parent-context contamination                              |
| SRC-FT content stamps in sensor-log.md       | `touch` of the log doesn't bypass the guard; stamps prove content was appended             |
| 3-block loop prevention budget               | If the agent is stuck without editing sources, don't trap it forever                       |
| Only declared sensors required               | No auto-REJECT for missing coverage/mutation; gaps → report, not finding                   |
| All-REPEAT convergence escape                | Same findings surviving a fix attempt → human breaks the tie; don't burn rounds            |
| No commit until GREEN                        | `git diff base` shows ALL implementation changes; WIP commits allowed for context overflow |
| `.harness/` excluded from staging/commit     | Harness artifacts are local state, not source code                                         |
| Single `.harness/active` file                | Only one gauntlet run at a time; concurrency is not supported                              |
| Path resolution before subagent spawn        | Fresh-context subagents cannot resolve `../../harness/` from the project root              |
| Guard utility modes (`--stamp`, `--abandon`) | Implementer stamps checkpoints; human disarms dropped runs                                 |
