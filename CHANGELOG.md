# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-24

### Added
- Initial release of Crew plugin
- 18 specialized AI agent skills for full-stack development workflow
- `workflow-orchestrator`: Main orchestration skill managing the entire SDLC
- `project-init`: Auto-detects project stack or collects preferences via interactive setup
- `backlog-decomposer`: Breaks down high-level requests into prioritized backlogs
- `user-story-generator`: Generates user stories from backlog items
- `wireframer`: Creates ASCII wireframes and navigation flowcharts
- `tech-lead`: Writes technical specifications and architecture design
- `product-designer`: Generates design specs and Figma designs (via MCP)
- `qa-tc`: Creates test cases in Given-When-Then format
- `be-spec`: Generates OpenAPI 3.0 specifications
- `be-test`: Writes backend test code (unit + integration)
- `be-main`: Implements backend APIs using TDD
- `fe-main`: Implements frontend with design spec and generated API clients
- `qa-e2e`: Writes and executes Playwright E2E tests
- `qa-visual-tester`: Visual QA testing with screenshots
- `be-lead`: Backend code review
- `fe-lead`: Frontend code review
- `ci`: Git workflow automation (branch, commit, PR, merge)
- `devops`: Local environment setup and deployment validation
- `crew-config.json` based project configuration system
- Support for multiple frameworks: NestJS, Express, FastAPI, Django, Next.js, React, Vue, etc.
- Configurable ID strategy (UUID, auto-increment, ULID, nanoid)
- Optional i18n support
- Figma MCP and Playwright MCP integrations
