# Crew

AI-powered full-stack development workflow for [Claude Code](https://claude.com/claude-code).

From backlog to deployment — Crew orchestrates 18 specialized AI agents across the entire software development lifecycle.

## What is Crew?

Crew is a Claude Code plugin that turns a single prompt like **"Build me a shopping mall"** into a fully working application through an automated pipeline:

```
Your request
     │
     ▼
┌─ Project Init ──── Detect stack or ask preferences
│
├─ Planning ──────── User stories → Wireframes → PO Review
│
├─ Design ────────── Tech spec → Test cases
│
├─ Preparation ───── Design spec + Figma │ Backend tests │ API spec  (parallel)
│
├─ Implementation ── Backend API │ Frontend UI  (parallel)
│
├─ QA ────────────── E2E tests → Bug fixes → PO Final Review
│
└─ Deployment ────── Commit → PR → CI checks → Merge
```

## Installation

### Via Plugin Marketplace (Recommended)

```bash
# 1. Add the marketplace
/plugin marketplace add gridi-ai/crew

# 2. Install the plugin
/plugin install crew@crew
```

Or use the interactive UI:

```
/plugin → Marketplaces → Add → gridi-ai/crew → Discover → Install
```

### Manual Installation

```bash
# Clone and use directly
git clone https://github.com/gridi-ai/crew.git
claude --plugin-dir /path/to/crew
```

## Quick Start

### 1. Start a workflow

```
/crew:workflow-orchestrator Build a user registration feature
```

Or for a full application:

```
/crew:workflow-orchestrator Build me a shopping mall
```

### 2. First run: Project Init

On first run, Crew automatically detects your project's tech stack:

- **Existing project?** → Auto-analyzes `package.json`, frameworks, DB, ORM, test tools, etc.
- **New project?** → Asks you to choose from preset options (framework, DB, styling, etc.)

The result is saved as `crew-config.json` in your project root.

### 3. Follow the workflow

Crew guides you through each phase with PO (Product Owner) review checkpoints. You approve or request changes at each review point.

## Skills

### Orchestration

| Skill | Description |
|-------|-------------|
| `workflow-orchestrator` | Main workflow coordinator — manages all phases |
| `project-init` | Project analysis and `crew-config.json` generation |
| `backlog-decomposer` | Breaks "build me X" into prioritized backlog items |

### Planning & Design

| Skill | Description |
|-------|-------------|
| `user-story-generator` | Generates user stories from backlog items |
| `wireframer` | Creates ASCII wireframes and navigation flows |
| `tech-lead` | Writes technical specifications and architecture |
| `product-designer` | Design specs + Figma designs (via MCP) |
| `qa-tc` | Test cases in Given-When-Then format |

### Implementation

| Skill | Description |
|-------|-------------|
| `be-spec` | OpenAPI 3.0 specification |
| `be-test` | Backend test code (TDD) |
| `be-main` | Backend API implementation |
| `fe-main` | Frontend UI with generated API clients |

### Quality Assurance

| Skill | Description |
|-------|-------------|
| `qa-e2e` | Playwright E2E tests (writes + executes) |
| `qa-visual-tester` | Visual QA with browser screenshots |
| `be-lead` | Backend code review |
| `fe-lead` | Frontend code review |

### Infrastructure

| Skill | Description |
|-------|-------------|
| `ci` | Git workflow (branch → commit → PR → CI → merge) |
| `devops` | Local environment setup and health checks |

## Supported Stacks

### Backend
- NestJS (TypeScript) — recommended
- Express (TypeScript)
- FastAPI (Python)
- Django (Python)
- Spring Boot (Java)
- Gin (Go)

### Frontend
- Next.js (React) — recommended
- React + Vite
- Vue 3 + Vite
- Svelte
- Angular

### Database
- PostgreSQL — recommended
- MySQL
- SQLite
- MongoDB

### Styling
- Tailwind CSS — recommended
- styled-components
- CSS Modules
- SCSS

## Configuration: crew-config.json

Crew generates a `crew-config.json` file that all skills reference:

```json
{
  "version": "1.0.0",
  "preferences": {
    "language": "en"
  },
  "project": {
    "name": "my-app",
    "type": "fullstack"
  },
  "backend": {
    "framework": "nestjs",
    "language": "typescript",
    "orm": "prisma",
    "testFramework": "jest"
  },
  "frontend": {
    "framework": "nextjs",
    "language": "typescript",
    "styling": "tailwindcss"
  },
  "database": {
    "type": "postgresql"
  },
  "conventions": {
    "idStrategy": "uuid",
    "i18n": true,
    "commitConvention": "conventional"
  },
  "tools": {
    "packageManager": "pnpm",
    "linter": "eslint",
    "formatter": "prettier",
    "ci": "github-actions"
  }
}
```

### Language Setting

Crew auto-detects the user's language from the initial prompt:

| Input | Detected |
|-------|----------|
| `Build a shopping mall` (English) | `en` |
| `쇼핑몰 만들어줘` (Korean) | `ko` |
| `ECサイトを作って` (Japanese) | `ja` |

All generated documents, communication, and outputs follow `preferences.language`. If no language is detected, Crew asks the user to choose.

### Customizable Conventions

| Setting | Options | Default |
|---------|---------|---------|
| `preferences.language` | Any ISO 639-1 code (`en`, `ko`, `ja`, `fr`, etc.) | `en` |
| `idStrategy` | `uuid`, `auto-increment`, `ulid`, `nanoid` | `uuid` |
| `i18n` | `true`, `false` | `true` |
| `commitConvention` | `conventional`, `freeform` | `conventional` |
| `branchStrategy` | `feature-branch`, `trunk-based` | `feature-branch` |

## Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh`) — for CI/PR automation
- [Node.js](https://nodejs.org/) or [Python](https://www.python.org/) — depending on your stack
- [Docker](https://www.docker.com/) (optional) — for containerized development

### Optional MCP Integrations

- **Figma MCP** (TalkToFigma) — enables automated Figma design generation
- **Playwright MCP** — enables browser-based visual QA testing

## Workflow Phases

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

### Skippable vs Mandatory Phases

| Phase | Skippable? | Condition |
|-------|-----------|-----------|
| Project Init | After first run | `crew-config.json` exists |
| PO Review #1 | Never | Always required |
| Tech Spec | Never | Always required |
| Test Cases | Never | Always required |
| Design/Figma | Yes | Backend-only backlog |
| BE Implementation | Yes | Frontend-only backlog |
| FE Implementation | Yes | Backend-only backlog |
| E2E Tests | Never | Always required (must execute) |
| PO Final Review | Never | Always required |
| CI/Deploy | Never | Always required |

## Output Structure

```
docs/
├── project-backlog.md              # Full backlog (Mode B only)
└── {backlog-keyword}/
    ├── user-stories.md
    ├── wireframes.md
    ├── tech-spec.md
    ├── test-cases.md
    ├── design-spec.md
    ├── openapi.yaml
    └── bug-reports/
        └── *.md

e2e/tests/{backlog-keyword}/
    └── *.spec.ts

crew-config.json                     # Project configuration
```

## License

[MIT](./LICENSE)

## Contributing

Contributions are welcome! Please open an issue or pull request on [GitHub](https://github.com/gridi-ai/crew).
