---
name: creating-skill
description: "Use when the user wants to create a new pi skill. Guides through defining the skill's purpose, structure, and format following established conventions."
---

# Create a New Skill

Turn an idea for a skill into a complete, well-structured SKILL.md file.

## Steps

### Step 1: Gather Requirements

First, check if a skill is needed:

| Scenario                            | Create a skill?        |
| ----------------------------------- | ---------------------- |
| Repeatable workflow with guardrails | Yes                    |
| One-off task                        | No — just do it        |
| Simple script                       | No — write it directly |

If a skill is needed, ask the user:

- What should the skill do? (1-2 sentences)
- When should it trigger? (user phrases, contexts)
- What's the expected output?

If unclear, ask one clarifying question at a time.

### Step 2: Choose Structure

Pick the structure that matches the complexity:

| Complexity               | Structure                           | Example       |
| ------------------------ | ----------------------------------- | ------------- |
| Simple, linear           | Steps (Step 1, Step 2, ...)         | tdd-workflow  |
| Moderate, some branching | Phases with conditions              | planning      |
| Complex, tiered flow     | Phases with sub-sections and tables | brainstorming |

**Default to Steps** unless the skill genuinely needs branching logic.

### Step 3: Draft the Skill

Follow this template:

````markdown
---
name: <skill-name>
description: "<When to use this skill. Be specific about trigger phrases.>"
---

# <Skill Title>

<1-2 sentence overview. State what it does and what it does NOT do.>

<HARD-GATE> (optional — only for the ONE critical non-negotiable rule)
<One non-negotiable rule. Do NOT repeat this in Constraints — HARD-GATE is the single source.>
</HARD-GATE>

## Steps

### Step 1: <Action>

<What to do. Rules and constraints.>

### Step 2: <Action>

<What to do. Rules and constraints.>

(... more steps ...)

## Example Conversation Flow

```
User: <typical request>

AI: <how the skill responds>

User: <follow-up>

AI: <continuation>
```

## Constraints

- <Guardrail 1>
- <Guardrail 2>
- <Guardrail 3>
````

**Concrete example — minimal skill:**

```markdown
---
name: validate-email
description: "Use when the user needs to validate email addresses. Checks format and domain."
---

# Validate Email

Validates email addresses against format rules and common domain patterns. Does not check if the mailbox exists.

## Steps

### Step 1: Get the email

Ask for the email address if not provided.

### Step 2: Validate format

Check: local@domain.tld structure, no spaces, valid characters.

### Step 3: Validate domain

Check: domain has MX record or is a known provider (gmail.com, outlook.com, etc.).

### Step 4: Report result

Return: valid/invalid with specific reason if invalid.

## Constraints

- Always check format before domain
- Never claim mailbox exists — only validate format and domain
```

### Step 4: Apply Format Rules

**Frontmatter:**

- `name`: lowercase, hyphenated, prefer gerund form (verb + -ing): `creating-skills`, `processing-pdfs`, `analyzing-data`
- `name` must match the folder name exactly (folder: `my-skill/`, frontmatter: `name: my-skill`)
- `description`: include trigger phrases the user might say

**Overview:**

- State what the skill does AND what it doesn't
- Link to related skills if handoff happens

**HARD-GATE** (optional):

- Use only when there's a single rule that must stop execution immediately
- The test: if breaking this rule would cause real harm (wrong behavior, wasted work, security issue), it's HARD-GATE worthy
- If it's just a best practice or quality guardrail, put it in Constraints instead
- Keep to one sentence
- Positioned at top of file for visual prominence
- Do NOT repeat this rule in the Constraints section

**Steps/Phases:**

- Each step = one action with a clear exit condition
- Rules go inside the step, not scattered
- Tables for conditional content (when to skip, when to use)

**Example:**

- Show a realistic dialogue, not pseudocode
- Include at least one user pushback or modification

**Constraints:**

- Group all guardrails at the bottom (except HARD-GATE — that stays at top)
- Start with "Never" for prohibitions, "Always" for requirements
- Keep to one line each — quick-reference, not prose

### Step 5: Self-Review

Check the drafted skill:

1. **Trigger clarity** — can you tell when to use this from the description?
2. **Step completeness** — does each step say what to do AND what not to do?
3. **No hidden logic** — are branching conditions explicit?
4. **Example covers the happy path** — does the example show the skill working end-to-end?

### Step 6: Save and Test

Save to `.pi/skills/<skill-name>/SKILL.md` (project-local) or `~/.pi/agent/skills/<skill-name>/SKILL.md` (global).

Skills can include supporting files:

- `references/` — supplementary context (schemas, cheatsheets, examples) when the skill needs reference material too large for the main file
- `scripts/` — executable code (Python/Bash) designed as tiny CLIs when the skill needs to run external tools

## Example Conversation Flow

```
User: I need a skill for code review.

AI: What should the skill do? Check for bugs, style issues, security, or all of the above?

User: Bugs and security. Style is handled by linter.

AI: When would you trigger this? After a PR is ready, before committing, or on demand?

User: Before committing, when I ask for it.

AI: [drafts skill with Steps, saves to .pi/skills/code-review/SKILL.md]

AI: "Skill saved to .pi/skills/code-review/SKILL.md. Want to test it?"
```

## Constraints

- Always ask one question at a time when gathering requirements
- Always default to simpler structure (Steps over Phases) unless branching is genuinely needed
- Always include rules inside each step, not just a title
- Always include an example conversation — skills without examples are harder to calibrate
- Always consolidate guardrails in a Constraints section, not scattered prose
- Never use HARD-GATE and Constraints for the same rule — HARD-GATE is the top-level stop signal, Constraints is the bottom-level reference list
