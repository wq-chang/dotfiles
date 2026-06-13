---
name: planning
description: "Use when you have a spec or requirements doc and need an implementation plan. Creates bite-sized, TDD-oriented tasks with exact file paths and complete code. Use after brainstorming or when the user says 'plan this', 'break this down', 'how should we build'."
---

# Implementation Planning

Turn a spec into a concrete implementation plan. This skill defines **HOW** to build. It does not implement code — that's execution.

<HARD-GATE>
Do NOT write code or invoke implementation skills until the plan is complete and approved.
</HARD-GATE>

## Principles

1. **Spec is source of truth** — build from the spec, don't reinvent behavior
2. **Decisions, not just tasks** — capture approach, boundaries, rationale
3. **Research before structuring** — explore the codebase before finalizing the plan
4. **Right-size** — small work gets a compact plan, large work gets more structure
5. **No placeholders** — every step has actual content an implementer needs

## Phases

### Phase 0: Resume or Start Fresh

Check `.pi-memories/plans/` for existing plans matching the topic.

**If a matching plan exists:** Ask: "Found an existing plan for [topic]. Update it, or start fresh?"

**If no match:** Proceed to Phase 1.

### Phase 1: Gather the Spec

**If a spec exists** (from brainstorming or otherwise): Read it. Use it as the primary input. Carry forward all decisions, requirements, scope boundaries, and outstanding questions.

**If no spec exists:** Ask the user what they want to build. Keep it brief — establish problem, behavior, scope, success criteria. If major product questions surface, suggest brainstorming first but continue if the user wants to proceed.

### Phase 2: Research the Codebase

Before structuring tasks, understand the existing code:

- Find files related to the feature (search by topic, patterns, conventions)
- Note existing patterns to follow (naming, structure, testing style)
- Identify what already exists that can be reused or extended
- Check for constraints (dependencies, APIs, config)

If the spec makes claims about the codebase (absent tables, missing routes, etc.), verify them now.

### Phase 3: Scope and Classify

Classify the work:

| Tier            | Signal                              | Plan depth                               |
| --------------- | ----------------------------------- | ---------------------------------------- |
| **Lightweight** | Small, well-bounded, low ambiguity  | Brief plan, fewer tasks                  |
| **Standard**    | Normal feature or bounded refactor  | Full plan with file structure and tasks  |
| **Deep**        | Cross-cutting, strategic, ambiguous | Full plan + decomposition into sub-plans |

If the spec covers multiple independent subsystems, suggest breaking into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

### Phase 4: Design the File Structure

Before defining tasks, map out which files will be created or modified:

- Each file has one clear responsibility
- Smaller, focused files over large ones that do too much
- Files that change together should live together
- Follow existing codebase patterns
- Use repo-relative paths always

This structure informs task decomposition. Each task produces self-contained changes.

### Phase 5: Write the Plan

Save to `.pi-memories/plans/YYYY-MM-DD-<feature-name>.md` (user preferences override).

#### Plan Header

Every plan starts with:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence — what this builds]

**Architecture:** [2-3 sentences — approach and key decisions]

**Spec:** [Path to origin spec, if any]
```

#### Task Structure

Each task is bite-sized (2-5 minutes per step). TDD-oriented when tests are applicable:

````markdown
### Task N: [Component Name]

**Files:**

- Create: `path/to/file.py`
- Modify: `path/to/existing.py`
- Test: `tests/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```
````

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```

#### Plan Sections

Include based on what's material:

| Section                 | When to include                      |
| ----------------------- | ------------------------------------ |
| Goal and architecture   | Always                               |
| File structure          | Always                               |
| Tasks with steps        | Always                               |
| Key technical decisions | When approach choices were made      |
| Dependencies            | When they affect sequencing          |
| Risks                   | When non-obvious                     |
| Test scenarios          | When test design needs specification |
| Out of scope            | When boundary clarification helps    |

### Phase 6: Self-Review

After writing the plan:

1. **Spec coverage** — can you point to a task for each requirement? Add missing tasks.
2. **Placeholder scan** — any "TBD", "TODO", "add error handling"? Fix them.
3. **Completeness** — every step has exact file paths, complete code, exact commands with expected output
4. **Consistency** — do types, method signatures, and names match across tasks?

Fix issues inline.

### Phase 7: Present and Handoff

> "Plan saved to `<path>`. Ready to execute?"

Wait for user approval. If changes requested, update and re-review.

**Execution options:**

1. **Execute now** — work through tasks in this session
2. **Execute later** — plan is ready when you are

## Key Rules

- **Exact file paths always** — never "somewhere in src/"
- **Complete code in every step** — if a step changes code, show the code
- **Exact commands with expected output** — never "run the tests"
- **No "similar to Task N"** — repeat the code; tasks may be read out of order
- **DRY, YAGNI, TDD, frequent commits**
- **One question at a time** when clarifying
