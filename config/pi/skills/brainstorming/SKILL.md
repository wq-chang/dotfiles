---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Into Designs

Turn ideas into designs and specs through collaborative dialogue. This skill explores **WHAT** to build. It does not implement — that's the planning skill.

<HARD-GATE>
Do NOT write code, scaffold projects, or invoke any implementation skill until the user has approved a design. No exceptions for "simple" work.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple"

Every project goes through this. A todo list, a utility, a config change — all benefit from examining assumptions before building. The design can be short, but you MUST present it and get approval.

## Phases

The process runs through Phases 0–6 in order. Create one task per numbered phase. Phase 1 sub-sections (1.1–1.4) are part of the same task.

## Phase 0: Resume or Start Fresh

Before any brainstorming, check `.pi-memories/specs/` for existing specs matching the topic.

**If a matching spec exists:** Read it. Ask: "Found an existing spec for [topic]. Resume from this, or start fresh?" If resuming, summarize current state, note outstanding questions, and continue from there.

**If no match:** Proceed to Phase 1.

## Phase 1: Understand the Idea

### 1.1 Scope Tiers

Classify the work before asking questions. Match ceremony to size:

| Tier            | Signal                                                 | Approach                                                     |
| --------------- | ------------------------------------------------------ | ------------------------------------------------------------ |
| **Lightweight** | Small, well-bounded, low ambiguity                     | Quick scan → brief questions → short spec or just alignment  |
| **Standard**    | Normal feature or bounded refactor with some decisions | Full dialogue → approaches → spec                            |
| **Deep**        | Cross-cutting, strategic, or highly ambiguous          | Full dialogue + extra rigor probes + decomposition if needed |

If the request describes multiple independent subsystems, flag it immediately. Help decompose into sub-projects; each gets its own spec → plan → implementation cycle.

### 1.2 Project Context

Depth matches the tier:

- **Lightweight** — targeted search for the topic, check if something similar exists, move on
- **Standard/Deep** — full context scan: files, docs, recent commits, existing patterns, constraints from project docs (AGENTS.md, strategy docs, etc.)

When the work touches existing code, verify claims against the actual codebase — don't assume tables, routes, configs, or dependencies exist without checking.

### 1.3 Pressure Test

**Standard and Deep only.** Lightweight skips this phase.

Before generating approaches, scan the user's opening for rigor gaps. Fire only the gaps that apply, as separate open-ended questions woven into the dialogue:

- **Evidence gap** — "What's the most concrete thing someone has already done about this?" (paid for it, built a workaround, etc.)
- **Specificity gap** — "Who specifically benefits, and what changes for them when this ships?"
- **Counterfactual gap** — "What do users do today when this comes up? What happens if nothing ships?"
- **Attachment gap** — "What's the smallest version that still delivers real value?"

After probing gaps, synthesize: Is there a nearby framing that creates more value without more cost? What's the single highest-leverage move right now?

### 1.4 Collaborative Dialogue

- **One question per message.** Stacking questions produces diluted answers.
- **Multiple choice for narrowing** — direction, priority, scope decisions.
- **Open-ended for pressure probes** — gap lenses in Phase 1.3 require real observation, not picked-from-a-menu answers.
- **Multi-select only** for compatible sets (goals, constraints, non-goals).
- **Open-ended for narrative questions** — when options would steer a diagnostic answer.
- Start broad (problem, users, value), then narrow (constraints, exclusions, edge cases).
- Ask what the user is already thinking before offering your own ideas.
- Bring alternatives and challenges — don't just interview.

**Convergence tracking:** After 5+ rounds without resolution, summarize what's known and ask: "Should we proceed with current understanding, or keep refining?" If the user wants to keep refining but isn't converging after 2 more rounds, recommend proceeding with current understanding or pausing the brainstorm.

## Phase 2: Explore Approaches

If multiple plausible directions exist, propose **2-3 approaches**. Otherwise state the recommended direction directly.

**Anti-genericness test:** If an approach would appear in a generic listicle for this problem, sharpen it against the project context or drop it. Use non-obvious angles: inversion (what if we did the opposite?), constraint removal, analogy from another domain.

For each approach:

- Brief description (2-3 sentences)
- Pros and cons
- Key risks or unknowns
- When it's best suited

Present all options first, then state your recommendation with reasoning. If one approach is clearly best, skip the menu.

If the user rejects all approaches, loop back with the new constraints they've revealed.

## Phase 3: Integration Check

Before writing the spec, mentally combine everything discussed. Surface non-obvious consequences the one-question-at-a-time flow may have missed:

"If X lives here AND we don't handle Y, then Z silently breaks."

One probe per genuine combination effect. This is a safety net for consequences you could have caught — not a punt list.

## Phase 4: Present the Design

Present the design section by section. Scale to complexity: a few sentences if straightforward, up to 200-300 words if nuanced.

Cover: architecture, components, data flow, error handling, testing. Ask after each section if it looks right.

**Design principles:**

- Units should have one clear purpose, communicate through well-defined interfaces
- Each unit: what does it do, how do you use it, what does it depend on?
- Can someone understand it without reading internals? Can you change internals without breaking consumers?

## Phase 5: Write the Spec

Save to `.pi-memories/specs/YYYY-MM-DD-<topic>-design.md` (user preferences override this path).

### Spec Sections

Include sections based on what's material:

| Section                          | When to include                          |
| -------------------------------- | ---------------------------------------- |
| Problem statement                | Always                                   |
| Goals and non-goals              | Always                                   |
| Design                           | Always                                   |
| Approach alternatives considered | When multiple approaches were discussed  |
| Decision log                     | When decisions were made during dialogue |
| Edge cases                       | When relevant to the design              |
| Outstanding questions            | When something is unresolved             |
| Dependencies                     | When they affect scope                   |

Capture each decision as it's made during dialogue — don't reconstruct from memory later.

### Spec Self-Review

After writing, check for:

1. **Placeholders** — any "TBD", "TODO", or vague requirements? Fix them.
2. **Consistency** — do sections contradict each other?
3. **Scope** — focused enough for one implementation plan?
4. **Ambiguity** — could any requirement be interpreted two ways? Pick one.

### User Review Gate

> "Spec written to `<path>`. Please review and let me know if you want changes before we write the implementation plan."

Wait for approval. If changes requested, update and re-review. Only proceed once approved.

## Phase 6: Transition

Invoke the **planning** skill to create an implementation plan from the spec. Do NOT invoke any other implementation skill. If the planning skill doesn't exist, present the spec and ask how the user wants to proceed.

## Example Conversation Flow

```
User: I want to add dark mode to the app.

AI: Who benefits from dark mode? Is this for all users, or a specific group?

User: Power users who work late at night.

AI: What do those users do today when the app is too bright? Do they use system-level dark mode, browser extensions, or just endure it?

User: They toggle system dark mode but our app ignores it.

AI: What's the smallest version that still delivers real value — full theme system, or just respect the OS preference?

User: Just OS preference for now.

AI: [presents 2-3 approaches — e.g., CSS prefers-color-scheme media query vs custom theme variable system vs class-based toggle]

User: Media query approach looks right.

AI: [presents design section by section — CSS variables, component updates needed, testing strategy]

User: Approved.

AI: [writes spec, self-reviews, saves to .pi-memories/specs/]

AI: "Spec written to .pi-memories/specs/2026-06-13-dark-mode-design.md. Please review."
```

## Constraints

- Never skip the user review gate on the spec
- Never assume claims about the codebase without verifying
- Always ask one question at a time
- Always capture decisions as they're made, not retrospectively
- Always offer to resume from existing specs
- Pressure test applies to Standard/Deep only — skip for Lightweight
- After 5+ rounds without convergence, surface it explicitly
