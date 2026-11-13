# Gate Governance Rules

All lifecycle gates MUST invoke OMP's built-in `ask` TUI tool. A command invocation, silence, or a previous approval is not consent.

- **Gate 1 (Alignment Gate):** validates the Alignment Summary before any specification file is written in `/work-spec`.
- **Gate 2 (Final Approval Gate):** validates the complete `proposal.md`, `design.md` and `tasks.md` before `/work-build`.
- **Quality Gate:** after all implementation tasks and focused checks pass, asks the user to choose either parallel AI review + QA or human review + QA. Automated mode requires both independent reports to PASS. Human mode requires explicit user confirmation that the user reviewed the current diff and verified behavior before `/work-ship`.

`/work-human` is documentation-only and runs only after an explicit Gate 2 `Approved` decision. It re-confirms that decision through `ask` and adds no gate of its own.

STRICT DIRECTIVES:
- Writing code before an explicit `Approved` at Gate 2 is prohibited.
- Before presenting Gate 2, run `rtk proxy openspec validate <slug>` and fix schema errors.
- Gate 1, Gate 2 and Quality Gate approvals are session-local. Never infer approval from files, checked tasks, reports, command invocation or a prior session.
- If a session resumes with unknown quality approval, re-run the quality choice through `/work-build` or obtain fresh explicit human confirmation before shipping.
