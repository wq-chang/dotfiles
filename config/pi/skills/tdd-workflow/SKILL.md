---
name: tdd-workflow
description: Test-first development workflow where AI writes tests before implementation. Use when the user wants TDD, "tests first", "write tests before code", "spec it out with tests", "define behavior before coding", or wants to review test cases before code is written.
---

# Test-First Development Workflow

This skill enforces a test-first workflow where tests are written and reviewed before implementation. Tests are written without implementation bias, so they define behavior rather than mirror code.

## Workflow Steps

### Step 1: Gather Requirements

Collect all requirements from the user. Ask clarifying questions if anything is ambiguous.

### Step 2: Write Tests Only

Write test cases that cover ALL requirements. Rules:

- **No implementation code** — only test files
- **Tests should fail** if run (no implementation yet)
- **Cover edge cases** — happy path, error cases, boundary conditions
- **Use descriptive test names** — each test name should explain the expected behavior

If the user already has partial tests, don't rewrite them. Identify gaps and write only the missing test cases.

If the request is too small or exploratory for TDD (e.g., a one-liner fix, a spike), say so and skip the workflow.

Present the test file(s) to the user for review.

### Step 3: User Reviews Tests

Wait for user confirmation before proceeding. The user may:

- Approve as-is
- Request changes to test cases
- Add missing test scenarios

Do NOT proceed to implementation until user explicitly approves.

### Step 4: (Optional) Implementation Plan

If the user wants extra review, provide a brief plan:

- File structure
- Key functions/classes
- Approach overview

Wait for approval before coding.

### Step 5: Implement Code

Write minimal implementation to pass all approved tests. Rules:

- **Only implement what tests cover** — no hidden features
- **Keep it simple** — don't over-engineer
- **Each test should guide a specific part of the implementation**

If the project already has existing code or tests:

- Review existing tests first to understand current coverage
- Write new tests only for uncovered requirements
- Don't rewrite existing tests unless they're insufficient

### Step 6: Run Tests Together

Run the test suite and show results. If any tests fail, debug and fix until all pass.

## Example Conversation Flow

```
User: I need a function that validates email addresses and a function that extracts domain from email.

AI: I'll write tests for both requirements first. Here are the test cases...
    [writes test file with email validation AND domain extraction tests]

User: Looks good, but add a test for email with subdomain.

AI: Added. Here's the updated test file...
    [updates tests]

User: Approved. Implement it.

AI: [implements code to pass all tests]

AI: Running tests... All 8 tests pass.
```

## When to Use This Workflow

| Scenario                             | Use TDD?                                              |
| ------------------------------------ | ----------------------------------------------------- |
| New feature with clear behavior      | Yes — write tests first                               |
| Bug fix                              | Yes — write a test that reproduces the bug first      |
| Refactor with no behavior change     | Yes — existing tests suffice, add tests for new paths |
| One-liner fix                        | Skip — too small for test-first                       |
| Exploratory spike                    | Skip — behavior not yet known                         |
| UI styling                           | Skip — visual, not behavioral                         |
| User explicitly asks for tests first | Yes — always honor                                    |
| User wants quick fix                 | Ask — offer TDD as option                             |

## Constraints

- Never skip the test review step
- Never implement before user approves tests
- Never add features not covered by approved tests
- Always run tests at the end and show results
