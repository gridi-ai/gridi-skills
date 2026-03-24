# gridi-skills

AI-powered development skill marketplace for [Claude Code](https://claude.com/claude-code) by [gridi.ai](https://github.com/gridi-ai).

## Plugins

| Plugin | Description | Skills |
|--------|-------------|--------|
| **[crew](#crew)** | Full-stack workflow orchestrator — backlog to deployment | 18 skills |
| **[code-review](#code-review)** | Backend & frontend code review | 2 skills |
| **[qa-suite](#qa-suite)** | QA automation — test cases, E2E, visual testing | 3 skills |
| **[api-builder](#api-builder)** | Backend API development with TDD | 5 skills |

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

---

## crew

Full-stack development workflow orchestrator. Turns a single prompt like **"Build me a shopping mall"** into a fully working application through an automated pipeline.

```bash
/plugin install crew@gridi-skills
```

```
/crew:workflow-orchestrator Build a user registration feature
```

### Workflow

```
Phase -1  │ Project Init        │ crew-config.json (first run only)
Phase -0  │ Project Inspection  │ Analyze current state
Phase  0  │ CI/DevOps Init      │ Branch creation, env setup
Phase  1  │ Planning            │ User stories + Wireframes + PO Review
Phase  2  │ Design              │ Tech spec + Test cases
Phase  3  │ Preparation         │ Design + BE tests + API spec (parallel)
Phase  4  │ Implementation      │ Backend + Frontend (parallel)
Phase  5  │ QA                  │ E2E tests + Bug fixes + PO Review
Phase  6  │ Deployment          │ Commit → PR → CI → Merge
```

### Skills (18)

| Category | Skills |
|----------|--------|
| Orchestration | `workflow-orchestrator`, `project-init`, `backlog-decomposer` |
| Planning | `user-story-generator`, `wireframer` |
| Design | `tech-lead`, `product-designer`, `qa-tc` |
| Implementation | `be-spec`, `be-test`, `be-main`, `fe-main` |
| QA | `qa-e2e`, `qa-visual-tester` |
| Review | `be-lead`, `fe-lead` |
| Infrastructure | `ci`, `devops` |

### Supported Stacks

| | Options |
|---|---------|
| **Backend** | NestJS, Express, FastAPI, Django, Spring Boot, Gin |
| **Frontend** | Next.js, React+Vite, Vue 3, Svelte, Angular |
| **Database** | PostgreSQL, MySQL, SQLite, MongoDB |
| **Styling** | Tailwind CSS, styled-components, CSS Modules, SCSS |

### Configuration

On first run, Crew generates `crew-config.json` with auto-detected or user-selected settings:

```json
{
  "version": "1.0.0",
  "preferences": { "language": "en" },
  "project": { "name": "my-app", "type": "fullstack" },
  "backend": { "framework": "nestjs", "language": "typescript" },
  "frontend": { "framework": "nextjs", "styling": "tailwindcss" },
  "conventions": { "idStrategy": "uuid", "i18n": true }
}
```

Language is auto-detected from user input — write in English, Korean, Japanese, or any language and Crew follows.

---

## code-review

Backend and frontend code review with confidence-based filtering.

```bash
/plugin install code-review@gridi-skills
```

### Skills

| Skill | Description |
|-------|-------------|
| `be-lead` | Backend architecture, security, and performance review |
| `fe-lead` | Frontend component quality, performance, and accessibility review |

### Features

- Architecture violation detection
- Security vulnerability scanning
- Performance anti-pattern identification
- Only reports high-confidence, high-severity issues

---

## qa-suite

QA automation from test case generation to E2E execution and visual testing.

```bash
/plugin install qa-suite@gridi-skills
```

### Skills

| Skill | Description |
|-------|-------------|
| `qa-tc` | Generate test cases in Given-When-Then format |
| `qa-e2e` | Write and **execute** Playwright E2E tests |
| `qa-visual-tester` | Visual QA with browser screenshots and issue reports |

### Features

- Given-When-Then (BDD) test case format
- Playwright test generation + mandatory execution
- Browser-based visual testing via MCP
- Automated bug report generation

---

## api-builder

Backend API development with TDD methodology.

```bash
/plugin install api-builder@gridi-skills
```

### Skills

| Skill | Description |
|-------|-------------|
| `project-init` | Auto-detect project stack or interactive setup |
| `tech-lead` | Write technical specifications and architecture |
| `be-spec` | Generate OpenAPI 3.0 specifications |
| `be-test` | Write backend test code (unit + integration) |
| `be-main` | Implement APIs to pass tests (TDD) |

### Features

- Configurable ID strategy (UUID, auto-increment, ULID, nanoid)
- Contract-First: OpenAPI spec as single source of truth
- Layered architecture (Controller → Service → Repository)
- Supports NestJS, Express, FastAPI, Django, Spring Boot, Gin

---

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
