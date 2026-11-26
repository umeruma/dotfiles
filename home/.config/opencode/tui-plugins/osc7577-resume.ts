// Tell the terminal how to bring the shown session back after a restart
// (OSC 7577, https://www.superlogical.com/rex/docs/build/program-resume).
// opencode 1.19 does not report it itself; Rex has a built-in rule for
// `opencode --session <id>`. Remove once opencode reports it itself
// (docs/src/content/docs/editor-stack.mdx).
import { createHash } from "node:crypto"
import { closeSync, openSync, writeSync } from "node:fs"

const token = process.env.OSC7577_TOKEN
// The shell tool's children must not report for this pid
delete process.env.OSC7577_TOKEN

const b64 = (s: string) => Buffer.from(s).toString("base64")

function report(sessionID: string) {
  const argv = ["opencode", "--session", sessionID].map(b64).join(",")
  const body = `pid=${process.pid}:time=${Math.floor(Date.now() / 1000)}:argv=${argv}:cwd=${b64(process.cwd())}`
  const mac = createHash("sha256").update(`${body}:${token}`).digest("hex")
  try {
    const fd = openSync("/dev/tty", "w")
    writeSync(fd, `\x1b]7577;${body}:mac=${mac}\x1b\\`)
    closeSync(fd)
  } catch {}
}

export default {
  id: "osc7577-resume",
  tui: async (api: any) => {
    if (!token) return
    let last = ""
    // shortcut: polls the route once a second; no route-change event is exposed to plugins in 1.19
    const timer = setInterval(() => {
      const route = api.route.current
      const id = route?.name === "session" ? route.params?.sessionID : undefined
      if (id && id !== last) {
        last = id
        report(id)
      }
    }, 1000)
    api.lifecycle.onDispose(() => clearInterval(timer))
  },
}
