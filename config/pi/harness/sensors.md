# Sensor Declaration Format

Sensors are the project's executable quality gates. The harness implementer
runs them at every checkpoint; the code reviewer verifies they ran. They are
**read by agents, not parsed by code** — the guard script never reads this
file, it only checks that sensor-log.md stays fresh.

A project declares sensors in ONE of two places (AGENTS.md wins if both exist):

## Option A: `## Sensors` block in the project AGENTS.md

```markdown
## Sensors

- typecheck: npx tsc --noEmit
- lint: npx eslint .
- test: npm test
- coverage: npm run coverage # optional
- coverage_threshold: 80 # optional, percent
- mutation: npx stryker run --incremental # optional
- mutation_score_min: 65 # optional, percent
```

## Option B: `harness.yaml` in the project root

```yaml
sensors:
  typecheck: npx tsc --noEmit
  lint: npx eslint .
  test: npm test
  coverage: npm run coverage # optional
  coverage_threshold: 80 # optional, percent
  mutation: npx stryker run --incremental # optional
  mutation_score_min: 65 # optional, percent
```

## Keys

| Key                  | Required | Meaning                                                   |
| -------------------- | -------- | --------------------------------------------------------- |
| `typecheck`          | yes*     | Command that type-checks / compiles without emitting.     |
| `lint`               | yes*     | Command that lints.                                       |
| `test`               | yes*     | Command that runs the test suite.                         |
| `coverage`           | no       | Command that produces a coverage percentage.              |
| `coverage_threshold` | no       | Minimum coverage percent; required if `coverage` is set.  |
| `mutation`           | no       | Command that runs mutation testing (incremental is fine). |
| `mutation_score_min` | no       | Minimum mutation score percent; required if `mutation` is set. |

\* Missing keys are legal: some projects have no linter or no type system.
The implementer runs what exists and lists the gaps in report.md.

## Rules

- Commands must already exist in the project. The harness never adds test
  frameworks, linters, or dependencies to satisfy this declaration.
- Order matters: checkpoints run `typecheck` → `lint` → `test`, stopping at
  the first failure.
- If neither AGENTS.md nor harness.yaml declares sensors, the plan writer
  notes the gap in plan.md and the human decides at the approval gate.
