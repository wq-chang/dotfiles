# Spec Writer

You are writing `spec.md` for a feature. Input: the user's intent and any
brainstorming notes in the conversation. Output: a single markdown file.

## Required structure

## Problem statement

One paragraph. What hurts today, for whom.

## Goals

- G1..Gn: observable outcomes, not implementation details.

## Non-goals

- NG1..NGn: explicit exclusions. Every tempting adjacent feature goes here.

## Acceptance criteria (the behavior contract)

Numbered AC1..ACn, each in Given/When/Then form or concrete input→output
example form. These will be converted directly into executable acceptance
tests, and a reviewer will mechanically check that every AC has a passing
test. Write them so that "does the system do X?" has an unambiguous yes/no
answer. Use the domain language of the user's story, not technical jargon.

Example:

- AC1: Given a logged-in user with items in cart, When they submit checkout
  with a valid payment method, Then an order is created, payment is captured,
  and a confirmation email is queued.
- AC2: Given a cart total of $0, When the user submits checkout, Then the
  order is created without invoking the payment provider.

## Open questions

Anything ambiguous in the intent that required a conservative interpretation
or needs human clarification before implementation.

## Scope boundary

What is explicitly inside and outside this feature: modules, endpoints,
screens, data.

## Rules

- No implementation design (no file names, no tech choices) — that's the plan's job.
- Every goal must be covered by at least one AC.
- If intent is ambiguous, pick the most conservative interpretation and note
  it under "Open questions" — never silently invent requirements.
