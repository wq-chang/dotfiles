# Adapter: pi

## Spawning a fresh-context reviewer

Use the `subagent` tool with `context: "fresh"`:
subagent({ agent: "<a general/reviewer-capable agent>", task: "<review task text>", context: "fresh" })
Review independence comes from context isolation — never review in the
implementer's context.

## End-of-session guard

Already active: `config/pi/extensions/harness-guard.ts` runs
`harness-guard.sh` on agent_end and injects the remediation as a follow-up.
No setup needed when this repo's config/pi is symlinked to ~/.pi/agent.

**Prerequisite:** verify that `config/pi/extensions/harness-guard.ts` exists
and is registered in the pi extension manifest. If missing, the guard will
not fire at end-of-session and stale sensor logs will go undetected.

Guard utility modes (used by the implementer and the human):
- `harness-guard.sh --stamp` — prints the `SRC-FT <mtime>` line the
  implementer appends to sensor-log.md at each checkpoint.
- `harness-guard.sh --abandon` — disarms an active run (removes
  .harness/active). The human's escape hatch for a dropped run.
