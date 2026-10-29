---
description: Small scoped git commit, push, optional PR using any free model.
---
- Dispatch execution to a free-model subagent (`agent: "sonic"`, routed to `@execution_tier`) using the `task` tool to run all git and PR operations without consuming paid model quotas.
- Change context: $1 (optional change slug or scope description). Flag: `--open-pr` (optional).
- If context matches an OpenSpec change (`openspec/changes/<context>`), inspect `proposal.md` and run `rtk proxy openspec validate` before committing to ensure spec validity.
- Formulate a concise, rollback-safe commit message citing the OpenSpec change slug, affected capabilities, and relevant REQ IDs.
- Stage and commit using `rtk git add` and `rtk git commit`.
- Push using `rtk git push`.
- If `--open-pr` is supplied, create a descriptive PR via `gh pr create` with problem context, changes, test evidence, labels, and assignee @me, derived from OpenSpec change artifacts.
