# Gate Governance Rules

All lifecycle gates MUST invoke OMP's built-in `ask` TUI tool. A command invocation, silence, or a previous approval is not consent.

- **Gate 1 (Alignment Gate):** validates the Alignment Summary before any specification file is written in `/work-spec`.
- **Gate 2 (Final Approval Gate):** validates the complete `proposal.md`, `design.md` and `tasks.md` before implementation in `/work-build <slug>`.
- **Quality Gate:** after implementation and focused checks, asks the user to choose parallel AI review + QA or human review + QA. The explicit quality-only actions `/work-build [slug] review-and-qa` and `/work-build [slug] qa-only` may be run independently against an existing change/current branch. Automated full quality approval requires both independent reports to PASS. QA-only is partial evidence and never satisfies the full ship gate. Human mode requires explicit user confirmation that the current diff was reviewed and behavior verified before `/work-ship`.

`/work-human` is documentation-only and runs only after an explicit Gate 2 `Approved` decision. It re-confirms that decision through `ask` and adds no gate of its own.

STRICT DIRECTIVES:
- Writing code before an explicit `Approved` at Gate 2 is prohibited.
- Before presenting Gate 2, run `rtk proxy openspec validate <slug>` and fix schema errors.
- Gate 1, Gate 2 and final quality approval are session-local. Never infer approval from files, checked tasks, reports, silence, command invocation or a prior session.
- Quality-only actions are read-only for project files and never imply implementation completion or ship approval.
- If a session resumes with unknown quality approval, rerun the required quality action through `/work-build` or obtain fresh explicit human confirmation before shipping.
