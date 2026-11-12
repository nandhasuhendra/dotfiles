# Gate Governance Rules

All lifecycle gates MUST invoke OMP's built-in `ask` TUI tool to enforce true, blocking human-in-the-loop governance:

- **Gate 1 (Alignment Gate):** Validates the `Alignment Summary` prior to physical document generation in `/work-spec`.
- **Gate 2 (Final Approval Gate):** Validates the complete specification suite and task checklist prior to code execution in `/work-build`.

STRICT DIRECTIVE:
- Writing code prior to an explicit 'Approved' status at Gate 2 is strictly prohibited.
- Bypassing gates without explicit user interaction through the `ask` dialog is strictly prohibited.
