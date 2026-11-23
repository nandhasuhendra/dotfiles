# Gate Governance Rules

All lifecycle gates MUST invoke OMP's built-in `ask` TUI tool. A command invocation, silence, or a previous approval is not consent.

- **Gate 1 (Alignment Gate):** validates the Alignment Summary before any specification file is written in `/work-spec`.
- **Gate 2 (Final Approval Gate):** validates the complete `proposal.md`, `design.md` and `tasks.md` before implementation in `/work-build <slug>`.
- **Quality Gate (advisory):** after implementation and focused checks, offers the user parallel AI review + QA or human review. The explicit quality-only actions `/work-build [slug] review-and-qa` and `/work-build [slug] qa-only` may be run independently against an existing change/current branch. Review/QA/security results are advisory evidence for the user: they are summarized into the OpenSpec change docs and human docs as a dated "Review Summary" entry, and never gate `/work-build` completion or `/work-ship`. Ship requires only the user's explicit confirmation that the diff was reviewed. Review actions dispatch at most 2 subagents.

`/work-human` is documentation-only and runs only after an explicit Gate 2 `Approved` decision. It re-confirms that decision through `ask` and adds no gate of its own.

STRICT DIRECTIVES:
- Writing code before an explicit `Approved` at Gate 2 is prohibited.
- Before presenting Gate 2, run `rtk openspec validate <slug>` and fix schema errors.
- Gate 1, Gate 2 and final quality approval are session-local. Never infer approval from files, checked tasks, reports, silence, command invocation or a prior session.
- Quality-only actions are read-only for project files and never gate implementation completion or shipping; their summaries are written back to the change docs and human docs.
- Review/QA dispatch is capped at 2 subagents per action.
- If a session resumes without explicit user review confirmation for the current diff, obtain it through `ask` before shipping; do not treat old reports as confirmation.
