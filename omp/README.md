# OMP Configuration

Personal configuration for [OMP](https://omp.sh) coding assistant, synchronized with OpenCode settings, MCP servers, agents, and skills.

## Structure

```text
omp/
├── README.md
├── mcp.json        # MCP server definitions (context7, gh_grep, playwright, filesystem, sequential-thinking, memory)
├── agents/         # Custom task agents for planning, architecture, security, and development
│   ├── document-orchestrator.md
│   ├── product-manager.md
│   ├── senior-architect-engineer.md
│   ├── senior-backend-engineer.md
│   ├── senior-devops-engineer.md
│   ├── senior-frontend-engineer.md
│   ├── senior-qa-engineer.md
│   ├── senior-security-engineer.md
│   └── team-leader.md
├── skills/         # Specialized agent skills (symlinked to opencode skills)
│   ├── caveman/
│   ├── skill-generalizer/
│   ├── skill-miner/
│   └── skill-personalizer/
├── extensions/    # Runtime extensions and hooks
│   └── zen-free-tier-headers.ts
├── commands/     # Custom slash commands (symlinked to opencode commands)
└── templates/     # PRD and Technical Document templates
    ├── PRD.md
    └── TECH-DOC.md
```

## Setup

Run the installer from repository root:

```bash
./install-omp.sh
```

This links:
- `omp/mcp.json` -> `~/.omp/agent/mcp.json`
- `omp/agents` -> `~/.omp/agent/agents`
- `omp/skills` -> `~/.omp/agent/skills`
- `omp/templates` -> `~/.omp/agent/templates`
- `omp/extensions` -> `~/.omp/agent/extensions`
- `omp/commands` -> `~/.omp/agent/commands`
Existing configurations are safely backed up before symlinks are created.

## Components

### MCP Servers

Configured in `mcp.json`:
- `context7`: Remote documentation and library context provider.
- `gh_grep`: Remote GitHub search provider (`grep.app`).
- `playwright`: Headless browser automation.
- `filesystem`: Local filesystem tools for `$HOME`.
- `sequential-thinking`: Step-by-step thinking scratchpad.
- `memory`: Local entity and relationship knowledge graph.

### Agents

Configured in `agents/`:
- `document-orchestrator`: Coordinates product, architecture, security, and team lead to produce reviewed PRD and Technical Documents.
- `product-manager`: Clarifies product goals, user needs, scope, and acceptance criteria.
- `team-leader`: Owns technical documents, diagrams, and dependency-aware task breakdowns.
- `senior-architect-engineer`: Designs system architecture, service boundaries, contracts, and migration plans.
- `senior-security-engineer`: Red-team attack path analysis and blue-team mitigation design.
- `senior-backend-engineer`: Server-side contracts, data models, and services.
- `senior-frontend-engineer`: Client interfaces, accessibility, and UI integrations.
- `senior-qa-engineer`: Risk-based verification and test planning.
- `senior-devops-engineer`: CI/CD, deployment safety, and operational readiness.

### Skills

Configured in `skills/`:
- `caveman`: Compressed communication mode for reduced token output while preserving technical precision.
- `skill-miner`: Mines session history and recurring workflows to draft candidate skills.
- `skill-personalizer`: Audits and adapts skills to the local developer environment and preferences.
- `skill-generalizer`: Prepares personal skills for public release by removing private paths and context.

### Extensions

Configured in `extensions/`:
- `zen-free-tier-headers.ts`: Runtime monkeypatch for OpenCode gateway free-tier validation headers and tool stubs.
