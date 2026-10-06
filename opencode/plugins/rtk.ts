import { execFile } from "node:child_process"
import { promisify } from "node:util"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.

const run = promisify(execFile)

export default {
  id: "rtk",
  async setup(ctx: {
    tool: {
      hook: (name: "execute.before", callback: (event: { tool: string; input: unknown }) => Promise<void>) => Promise<unknown>
    }
  }) {
    try {
      await run("rtk", ["--version"], { timeout: 5000 })
    } catch {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", async (event) => {
      const tool = String(event.tool).toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const input = event.input
      if (!input || typeof input !== "object") return

      const args = input as Record<string, unknown>
      const command = args.command
      if (typeof command !== "string" || !command) return

      try {
        const { stdout } = await run("rtk", ["rewrite", command], { timeout: 5000 })
        const rewritten = stdout.trim()
        if (rewritten && rewritten !== command) args.command = rewritten
      } catch {
        // Rewrite failed — execute the original command.
      }
    })
  },
}
