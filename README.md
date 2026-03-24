# gridi-skills

AI-powered development skill marketplace for [Claude Code](https://claude.com/claude-code) by [gridi.ai](https://app.gridi.ai).

## Plugins

| Plugin | Description | |
|--------|-------------|-|
| **crew** | Full-stack workflow orchestrator — backlog to deployment (18 skills) | [README →](./plugins/crew/README.md) |
| **code-review** | Backend & frontend code review with architecture, security, and performance checklists (2 skills) | [README →](./plugins/code-review/README.md) |
| **qa-suite** | QA automation — test case generation, Playwright E2E, visual testing (3 skills) | [README →](./plugins/qa-suite/README.md) |
| **api-builder** | Backend API development with TDD — tech spec to implementation (5 skills) | [README →](./plugins/api-builder/README.md) |

## Installation

```bash
# 1. Add the marketplace (once)
/plugin marketplace add gridi-ai/gridi-skills

# 2. Install any plugin you need
/plugin install crew@gridi-skills
/plugin install code-review@gridi-skills
/plugin install qa-suite@gridi-skills
/plugin install api-builder@gridi-skills
```

Or use the interactive UI:

```
/plugin → Marketplaces → Add → gridi-ai/gridi-skills → Discover → Install
```

## Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh`) — for CI/PR automation (crew, api-builder)
- [Node.js](https://nodejs.org/) or [Python](https://www.python.org/) — depending on your stack

### Optional MCP Integrations

- **Figma MCP** (TalkToFigma) — automated Figma design generation (crew)
- **Playwright MCP** — browser-based visual QA testing (qa-suite)

## License

[MIT](./LICENSE)

## Contributing

Contributions are welcome! Please open an issue or pull request on [GitHub](https://github.com/gridi-ai/gridi-skills).
