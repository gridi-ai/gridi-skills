# qa-suite

QA automation from test case generation to E2E execution and visual testing.

## Installation

```bash
/plugin marketplace add gridi-ai/gridi-skills
/plugin install qa-suite@gridi-skills
```

## Skills

| Skill | Description |
|-------|-------------|
| `qa-tc` | Generate test cases in Given-When-Then format |
| `qa-e2e` | Write and **execute** Playwright E2E tests |
| `qa-visual-tester` | Visual QA with browser screenshots and issue reports |

## Features

- **Given-When-Then (BDD)** test case format
- Playwright test generation + **mandatory execution**
- Browser-based visual testing via Playwright MCP
- Automated bug report generation with screenshots

## Usage

```
/qa-suite:qa-tc Generate test cases for the auth module
/qa-suite:qa-e2e Write and run E2E tests for login flow
/qa-suite:qa-visual-tester Run visual QA on the dashboard page
```

## qa-tc — Test Case Generator

Generates structured test cases from tech specs:

- Positive / Negative / Boundary value tests
- Given-When-Then format for each case
- TC ID mapping for traceability
- Priority classification (Critical / High / Medium / Low)

## qa-e2e — E2E Test Runner

Writes Playwright tests and **executes them** (not just generation):

- Tests against a real running server (no mocking)
- Generates bug reports for failures
- Supports test-fix-retest feedback loops

## qa-visual-tester — Visual QA

Browser-based visual testing using Playwright MCP:

- QA test sheet generation from requirements
- Screenshot capture and comparison
- Issue reports with evidence (screenshots + steps to reproduce)

### Optional MCP Integration

- **Playwright MCP** — required for `qa-visual-tester`, recommended for `qa-e2e`
