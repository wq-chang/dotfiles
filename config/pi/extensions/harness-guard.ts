/**
 * harness-guard — hard end-of-run sensor enforcement (pi glue).
 *
 * On agent_end, runs the shared guard script. If it reports staleness
 * (exit 1), the remediation text is sent as a follow-up message so the
 * agent runs sensors / closes the harness run instead of finishing.
 * Fresh (exit 0) and budget-exhausted blocks pass silently.
 *
 * Unexpected failures (guard crash, timeout, kill) are surfaced via
 * ctx.ui.notify so a broken guard never fails silently open.
 *
 * The script resolves the project root itself via git; pi.exec inherits
 * the session cwd, so no cwd plumbing is needed.
 */
import { fileURLToPath } from "node:url";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const GUARD = join(
  fileURLToPath(new URL(".", import.meta.url)),
  "../harness/guard/harness-guard.sh",
);

export default function (pi: ExtensionAPI) {
  pi.on("agent_end", async (_event, ctx) => {
    try {
      const { code, killed, stdout, stderr } = await pi.exec("bash", [GUARD], { timeout: 15000 });
      if (code === 1 && stdout.trim()) {
        pi.sendUserMessage(stdout.trim(), { deliverAs: "followUp" });
      } else if (code !== 0 || killed) {
        const detail = stderr.trim() || stdout.trim() || "(no output)";
        ctx.ui.notify(`harness-guard failed (exit ${code}${killed ? ", killed" : ""}): ${detail}`, "error");
      }
    } catch (err) {
      ctx.ui.notify(`harness-guard could not run: ${err instanceof Error ? err.message : String(err)}`, "error");
    }
  });
}
