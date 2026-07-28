# Plan Writer

You are writing `plan.md` from an approved-in-draft `spec.md`.

## Required structure

## Architecture

2-5 sentences: approach and key decisions, referencing the project's existing
patterns (read the codebase first — follow its conventions).

## Tasks

Ordered, bite-sized tasks (TDD: failing test → implementation → green).
Group tasks into slices; each slice ends with at least one acceptance
criterion becoming verifiable end-to-end.

Format per task:

### Task N: <name>

- Covers: AC<n> (list every AC this task advances)
- Slice: <slice name>
- Steps: red → green → refactor, in the project's existing test runner

## AC coverage table

| AC | Task(s) | Slice |
Every AC1..ACn from spec.md must appear. An AC with no task = plan is invalid.

## Sensor checkpoints

Restate the timing contract (from the sensor block in the project's AGENTS.md
or harness.yaml; format: ../../harness/sensors.md):

- After EVERY task: typecheck → lint → test (in that order); log each run to
  sensor-log.md
- After each slice: coverage vs threshold; acceptance tests for the slice's ACs
- At the end: full sweep incl. mutation (incremental, changed files)

## Rules

- Tasks are sequential — one at a time, no parallelism.
- Follow the project's existing test conventions; do not introduce new test
  frameworks or new dependencies to satisfy this plan.
