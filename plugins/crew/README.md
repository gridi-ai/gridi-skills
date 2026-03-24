# crew

Full-stack development workflow orchestrator. Turns a single prompt like **"Build me a shopping mall"** into a fully working application through an automated pipeline.

## Installation

```bash
/plugin marketplace add gridi-ai/gridi-skills
/plugin install crew@gridi-skills
```

## Quick Start

```
/crew:workflow-orchestrator Build a user registration feature
```

Or for a full application:

```
/crew:workflow-orchestrator Build me a shopping mall
```

## Workflow

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

## Skills (18)

| Category | Skills |
|----------|--------|
| Orchestration | `workflow-orchestrator`, `project-init`, `backlog-decomposer` |
| Planning | `user-story-generator`, `wireframer` |
| Design | `tech-lead`, `product-designer`, `qa-tc` |
| Implementation | `be-spec`, `be-test`, `be-main`, `fe-main` |
| QA | `qa-e2e`, `qa-visual-tester` |
| Review | `be-lead`, `fe-lead` |
| Infrastructure | `ci`, `devops` |

## Supported Stacks

| | Options |
|---|---------|
| **Backend** | NestJS, Express, FastAPI, Django, Spring Boot, Gin |
| **Frontend** | Next.js, React+Vite, Vue 3, Svelte, Angular |
| **Database** | PostgreSQL, MySQL, SQLite, MongoDB |
| **Styling** | Tailwind CSS, styled-components, CSS Modules, SCSS |

## Configuration

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

### Language

Language is auto-detected from user input — write in English, Korean, Japanese, or any language and Crew follows. All generated documents and communication use the detected language.

### Customizable Conventions

| Setting | Options | Default |
|---------|---------|---------|
| `preferences.language` | Any ISO 639-1 code | `en` |
| `idStrategy` | `uuid`, `auto-increment`, `ulid`, `nanoid` | `uuid` |
| `i18n` | `true`, `false` | `true` |
| `commitConvention` | `conventional`, `freeform` | `conventional` |
| `branchStrategy` | `feature-branch`, `trunk-based` | `feature-branch` |

## Skippable vs Mandatory Phases

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
├── project-backlog.md
└── {backlog-keyword}/
    ├── user-stories.md
    ├── wireframes.md
    ├── tech-spec.md
    ├── test-cases.md
    ├── design-spec.md
    ├── openapi.yaml
    └── bug-reports/

e2e/tests/{backlog-keyword}/
    └── *.spec.ts

crew-config.json
```

## Optional MCP Integrations

- **Figma MCP** (TalkToFigma) — automated Figma design generation
- **Playwright MCP** — browser-based visual QA testing
