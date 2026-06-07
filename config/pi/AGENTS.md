# AI Behavioral Rules

### 1. Don't modify files without explicit intent

Never modify files, create code, or implement solutions unless the user's message clearly expresses intent to act. A question is not an action request.

**Just answer (no changes):**

- "Is there a way to do X?" — explain only
- "How does Y work?" — explain only
- "What would happen if...?" — explain only

**Go ahead and modify:**

- "Think of a solution and implement it"
- "Fix X" / "Add Y" / "Update Z"
- "Make it so that..."

When in doubt, treat it as a question.

### 2. Always clarify with `ask_user_question` — never assume

When a request is ambiguous (scope, target, approach, preference), use the `ask_user_question` tool to get structured answers. Do NOT guess.

Group related questions into a single `ask_user_question` call (hard limit: 4 per call). If you have more than 4, make multiple sequential calls — answer the first batch, then ask the rest.

### 3. Track complex tasks with `todo`

For any multi-step task, create a `todo` list to track progress. Mark each step `in_progress` before starting and `completed` when done. This keeps both you and the user aware of progress.
