import { tool } from "@opencode-ai/plugin";
import { exec } from "child_process";
import { promisify } from "util";
const execAsync = promisify(exec);
export default tool({
  description:
    "Capture text output from a kitty terminal pane or tab using kitty's remote control. Useful for getting terminal content to analyze or debug.",
  args: {
    action: tool.schema
      .enum(["capture", "list"])
      .optional()
      .describe(
        "Action to perform: 'capture' to get text (default), 'list' to show available windows with their IDs, titles, and running processes",
      ),
    match: tool.schema
      .string()
      .optional()
      .describe(
        "Match criteria for selecting the window (e.g., 'id:1', 'id:3', 'title:my-app'). Use 'list' action to find window IDs. Defaults to 'id:1'",
      ),
    extent: tool.schema
      .enum(["screen", "all", "selection"])
      .optional()
      .describe(
        "What text to capture: 'screen' (visible), 'all' (scrollback + screen), 'selection'. Defaults to 'screen'. Ignored when action is 'list'",
      ),
  },
  async execute(args) {
    const { action = "capture", match = "id:1", extent = "screen" } = args;
    try {
      // Find kitty socket
      const { stdout: socketList } = await execAsync(
        "ls /tmp/kitty-* 2>/dev/null | head -1",
      );
      const socket = socketList.trim();
      if (!socket) {
        throw new Error(
          "No kitty socket found in /tmp/. Ensure kitty remote control is enabled (allow_remote_control yes in kitty.conf)",
        );
      }
      if (action === "list") {
        // List windows with id, title, and foreground process
        const { stdout, stderr } = await execAsync(
          `kitty @ --to "unix:${socket}" ls`,
        );

        if (stderr) {
          return stderr;
        }
        try {
          // Try to parse and format with jq if available
          const { stdout: formatted } =
            await execAsync(`echo '${stdout}' | jq -r '
            .[] | .tabs[] | .windows[] |
            "id:\\(.id) | title: \\(.title) | process: \\(.foreground_processes[0].cmdline | join(" "))"
          ' 2>/dev/null`);
          return formatted;
        } catch {
          // Fallback to raw output if jq is not available or parsing fails
          return stdout;
        }
      }
      // Capture the text
      const { stdout, stderr } = await execAsync(
        `kitty @ --to "unix:${socket}" get-text --match "${match}" --extent "${extent}"`,
      );

      if (stderr) {
        return stderr;
      }

      return stdout;
    } catch (error) {
      return `Error: ${error instanceof Error ? error.message : String(error)}`;
    }
  },
});
