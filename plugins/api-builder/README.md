# api-builder

Backend API development with TDD methodology — from tech spec to working implementation.

## Installation

```bash
/plugin marketplace add gridi-ai/gridi-skills
/plugin install api-builder@gridi-skills
```

## Skills

| Skill | Description |
|-------|-------------|
| `project-init` | Auto-detect project stack or interactive setup → `crew-config.json` |
| `tech-lead` | Write technical specifications and architecture design |
| `be-spec` | Generate OpenAPI 3.0 specifications |
| `be-test` | Write backend test code (unit + integration) |
| `be-main` | Implement APIs to pass tests (TDD) |

## Features

- **Contract-First**: OpenAPI spec as single source of truth
- **TDD workflow**: Write tests first, then implement
- **Layered architecture**: Controller → Service → Repository
- Configurable ID strategy (UUID, auto-increment, ULID, nanoid)
- Auto-detection of existing project stack

## Usage

```
/api-builder:project-init
/api-builder:tech-lead Write a tech spec for user authentication
/api-builder:be-spec Generate OpenAPI spec from the tech spec
/api-builder:be-test Write tests based on test cases
/api-builder:be-main Implement the API to pass all tests
```

## Supported Stacks

| Language | Framework | ORM |
|----------|-----------|-----|
| Node.js | NestJS, Express | Prisma, TypeORM |
| Python | FastAPI, Django | SQLAlchemy, Django ORM |
| Go | Gin, Echo | GORM, Ent |
| Java | Spring Boot | JPA, MyBatis |

## Configuration

On first run, `project-init` generates `crew-config.json`:

```json
{
  "version": "1.0.0",
  "preferences": { "language": "en" },
  "project": { "name": "my-api", "type": "backend-only" },
  "backend": {
    "framework": "nestjs",
    "language": "typescript",
    "orm": "prisma",
    "testFramework": "jest"
  },
  "conventions": { "idStrategy": "uuid" }
}
```

## Workflow

```
tech-lead → be-spec → be-test → be-main
   │           │          │         │
   ▼           ▼          ▼         ▼
tech-spec   openapi    tests    implementation
  .md        .yaml    .test.ts   (passes tests)
```
