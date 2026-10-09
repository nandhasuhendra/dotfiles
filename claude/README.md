# Claude Code Configuration

Personal configuration for [Claude Code](https://code.claude.com/docs): custom subagents, slash commands, skills, and document templates.

## Structure

```text
claude/
├── README.md
├── agents/         # Subagents (adapted from opencode/agents for Claude Code frontmatter)
│   ├── document-orchestrator.md
│   ├── product-manager.md
│   ├── senior-architect-engineer.md
│   ├── senior-backend-engineer.md
│   ├── senior-devops-engineer.md
│   ├── senior-frontend-engineer.md
│   ├── senior-qa-engineer.md
│   ├── senior-security-engineer.md
│   └── team-leader.md
├── commands/       # Slash commands (symlink to ../opencode/commands)
├── skills/         # Agent skills (symlink to ../opencode/skills)
└── templates/      # PRD and Technical Document templates (symlink to ../opencode/templates)
```

## Setup

Run the installer from repository root:

```bash
./install-claude.sh
```

This links:

- `claude/agents` -> `~/.claude/agents`
- `claude/commands` -> `~/.claude/commands`
- `claude/skills` -> `~/.claude/skills`
- `claude/templates` -> `~/.claude/templates`

Existing configurations are safely backed up before symlinks are created.

## Components

### Subagents (`~/.claude/agents/`)

Nine role agents for the planning, review, and implementation workflow, matching the OpenCode and OMP agents:

| Agent | Purpose |
|---|---|
| `document-orchestrator` | Orchestrates PM, Team Leader, Architect, and Security Engineer into a reviewed PRD and technical document |
| `product-manager` | PRD authoring: problem framing, user journeys, requirements, acceptance criteria |
| `team-leader` | Technical document, architecture, and dependency-aware task breakdown |
| `senior-architect-engineer` | Architecture, boundaries, tradeoffs, and migration plans |
| `senior-backend-engineer` | Backend services, APIs, data models, and integrations |
| `senior-frontend-engineer` | Accessible, responsive frontend experiences and client integrations |
| `senior-qa-engineer` | Risk-based test plans and reproducible defect reports |
| `senior-security-engineer` | Attack-path assessment and defensive controls |
| `senior-devops-engineer` | CI/CD, infrastructure, deployment safety, and service operations |

Claude Code requires `name` and `description` in the frontmatter, so these files are adapted copies of `opencode/agents/` (the `mode` field is dropped, template paths point at `~/.claude/templates/`); the prompts are otherwise identical.

### Slash commands (`~/.claude/commands/`)

Shared with OpenCode, invoked as `/planning`, `/implement`, `/security-review`, `/qa-testing`, `/git-sync`, and the rest of the command set. `$ARGUMENTS` works the same way as in OpenCode.

### Skills (`~/.claude/skills/`)

Shared with OpenCode: `caveman`, `skill-generalizer`, `skill-miner`, `skill-personalizer`. Claude Code loads each `SKILL.md` automatically or via `/skill-name`.

### Templates (`~/.claude/templates/`)

`PRD.md` and `TECH-DOC.md`, referenced by the subagents and review commands as the canonical document formats.
