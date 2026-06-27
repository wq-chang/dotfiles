import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * /clear — Clear the terminal conversation display without clearing the AI's context.
 *
 * Writes ANSI escape sequences to clear the terminal screen and scrollback buffer.
 * The session context (messages, memory) is fully preserved — you can re-read
 * anything via /tree.
 *
 * Usage:
 *   /clear         — Clear screen + scrollback
 */
export default function (pi: ExtensionAPI) {
  pi.registerCommand("clear", {
    description: "Clear terminal screen (preserves conversation context)",
    handler: async (_args, ctx) => {
      // ANSI escape sequences:
      //   \x1b[2J  — clear entire screen
      //   \x1b[H   — move cursor to home position
      //   \x1b[3J  — clear scrollback buffer (supported by xterm, kitty,
      //              ghostty, wezterm, iTerm2, Windows Terminal, etc.)
      process.stdout.write("\x1b[2J\x1b[H\x1b[3J");

      // Brief confirmation in the TUI notification area
      ctx.ui.notify("✓ Screen cleared — context preserved (see /tree)", "info");
    },
  });
}
