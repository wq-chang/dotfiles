---
name: harness-spec
description: "Generate a reviewed feature spec + TDD plan with an independent AI review loop, stopping at the human approval gate. Use when starting a new feature: after the user describes intent, before any implementation."
---

# Harness: Spec & Plan

Automates: spec → plan → independent review loop → **human gate**. Does NOT
implement anything.

## Scope check

Bug fixes, single functions, small well-understood changes → this skill is
overkill. Use `tdd-workflow` (user reviews tests) or work directly. This
skill is for full features where the human will NOT review code or tests.

Prompt files referenced below resolve relative to this skill directory:
`../../harness/prompts/<file>.md`. Subagent spawning: follow
`../../harness/adapters/pi.md` (or the adapter matching the current CLI).
Any path beginning `../../harness/` in this file or the prompts it
references resolves against this skill directory — substitute the
absolute path on disk when executing commands.

## Flow

1. **Slug** — derive a kebab-case feature slug from the user's intent.
   Create `.harness/<slug>/` in the project root.
2. **Write spec** — read `../../harness/prompts/spec-writer.md` and follow it
   to produce `.harness/<slug>/spec.md`.
3. **Write plan** — read `../../harness/prompts/plan-writer.md` and follow it
   to produce `.harness/<slug>/plan.md`. Read the project's sensor block
   first (AGENTS.md or harness.yaml); if neither declares sensors, note the
   gap in plan.md.
4. **Independent review** — spawn a fresh-context subagent (per adapter) with
   this task: "Read `../../harness/prompts/spec-reviewer.md` and follow it.
   User intent: <verbatim intent>. Spec: .harness/<slug>/spec.md. Plan:
   .harness/<slug>/plan.md." For rounds ≥2, append: "Prior review rounds:
   .harness/<slug>/review.md — mark each finding NEW or REPEAT." Append its
   full output to `.harness/<slug>/review.md` under a `## Round N` heading.
5. **Loop** — VERDICT: REJECT → revise spec/plan against findings, review
   again. Convergence escape: if a round's blocker findings are all REPEATs
   (the same issues surviving a revision attempt), stop looping immediately
   and continue to step 6 — the human breaks the tie. Hard cap: 3 rounds;
   if still rejecting, keep the findings visible and continue to step 6.
6. **HUMAN GATE (hard stop)** — present: spec.md, plan.md, review.md paths +
   a 5-line summary. Say exactly: "Spec and plan ready for your review.
   Say 'approved' to unlock the gauntlet." Do NOT proceed to implementation,
   do NOT create .harness/active.
