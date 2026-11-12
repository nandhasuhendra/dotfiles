# Gate Governance Rules

All lifecycle gates MUST invoke OMP's built-in `ask` TUI tool. A command invocation, silence, or a previous approval is not consent.

- **Gate 1 (Alignment Gate):** validates the Alignment Summary before any specification file is written in `/work-spec`.
- **Gate 2 (Final Approval Gate):** validates the complete `proposal.md`, `design.md` and `tasks.md` before `/work-build`.

`/work-human` is documentation-only and runs only after an explicit Gate 2 `Approved` decision. It re-confirms that decision through `ask` and adds no gate of its own.

STRICT DIRECTIVES:
- Writing code before an explicit `Approved` at Gate 2 is prohibited.
- Before presenting Gate 2, run `rtk proxy openspec validate <slug>` and fix schema errors.
- Gate confirmations are session-local. Never infer approval from files, checked tasks, command invocation or a prior session. If `/work-build` starts or resumes without Gate 2 approval available in the current session context, re-confirm it through `ask` before editing code.
