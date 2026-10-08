# Antigravity

`agents/` contains Antigravity-compatible versions of all nine agents in `opencode/agents/`: `document-orchestrator`, `product-manager`, `team-leader`, `senior-architect-engineer`, `senior-backend-engineer`, `senior-frontend-engineer`, `senior-qa-engineer`, `senior-devops-engineer`, and `senior-security-engineer`. The orchestrator is a primary agent; the other eight can be selected directly or delegated to as subagents.

The document orchestrator hands the draft from Team Leader to Architect and Security Engineer before Team Leader's final revision. Security review is document-only and feeds prioritized findings and mitigations back into the design and task breakdown.

From the dotfiles repository, run:

```sh
./install-antigravity.sh
```

The installer links each `agent.md` into `~/.gemini/config/agents/<name>/agent.md` without replacing unrelated agents or settings; conflicting agent files are backed up. In Antigravity CLI, reopen `/agents` to select an agent or ask the current agent to delegate to one. For PRD and technical-document work, the agents use the templates at `~/.config/opencode/templates/` (installed via `./install-opencode.sh`); if those templates are not installed, they will ask for their location.
