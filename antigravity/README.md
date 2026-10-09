# Antigravity

`agents/` contains Antigravity-compatible versions of all nine agents in `opencode/agents/`: `document-orchestrator`, `product-manager`, `team-leader`, `senior-architect-engineer`, `senior-backend-engineer`, `senior-frontend-engineer`, `senior-qa-engineer`, `senior-devops-engineer`, and `senior-security-engineer`. The orchestrator is a primary agent; the other eight can be selected directly or delegated to as subagents.

The document orchestrator hands the draft from Team Leader to Architect and Security Engineer before Team Leader's final revision. Security review is document-only and feeds prioritized findings and mitigations back into the design and task breakdown.

From the dotfiles repository, run:

```sh
./install-antigravity.sh
```

The installer links each `agent.md` into `~/.gemini/config/agents/<name>/agent.md`, links `rules/custom-commands.md` into `~/.gemini/config/rules/`, registers `plugins/custom-commands/` in `~/.gemini/config/plugins.json`, and includes the custom commands rule in `~/.gemini/config/GEMINI.md`. Conflicting files are backed up safely.
