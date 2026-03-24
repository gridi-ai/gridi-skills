# Agent Dependencies Guide

## Dependency Graph

```
user-story-generator
         │
         ▼
    wireframer
         │
         ▼
    tech-lead
         │
         ▼
      qa-tc
         │
    ┌────┼────┬─────────────┐
    ▼    ▼    ▼             │
 PD   BE-Test BE-Spec       │
 │       │      │           │
 │       └──┬───┘           │
 │          ▼               │
 │      BE-Main             │
 │          │               │
 └────┬─────┘               │
      ▼                     │
   FE-Main ◀────────────────┘
      │
      ▼
   QA-E2E
```

## Dependencies by Agent

### user-story-generator
- **Input Dependencies**: None (only the backlog is needed)
- **Output**: docs/{backlog-keyword}/user-stories.md

### wireframer
- **Input Dependencies**: user-story-generator
- **Required Files**: docs/{backlog-keyword}/user-stories.md
- **Output**: docs/{backlog-keyword}/wireframes.md

### tech-lead
- **Input Dependencies**: user-story-generator, wireframer
- **Required Files**:
  - docs/{backlog-keyword}/user-stories.md
  - docs/{backlog-keyword}/wireframes.md
- **Output**: docs/{backlog-keyword}/tech-spec.md

### qa-tc
- **Input Dependencies**: tech-lead
- **Required Files**: docs/{backlog-keyword}/tech-spec.md
- **Output**: docs/{backlog-keyword}/test-cases.md

### product-designer
- **Input Dependencies**: wireframer, tech-lead
- **Required Files**:
  - docs/{backlog-keyword}/wireframes.md
  - docs/{backlog-keyword}/tech-spec.md
- **Output**:
  - Figma file
  - docs/{backlog-keyword}/design-spec.md
- **Parallelizable**: Can run simultaneously with be-test, be-spec

### be-test
- **Input Dependencies**: qa-tc, tech-lead
- **Required Files**:
  - docs/{backlog-keyword}/test-cases.md
  - docs/{backlog-keyword}/tech-spec.md
- **Output**: tests/**/*.test.ts
- **Parallelizable**: Can run simultaneously with product-designer, be-spec

### be-spec
- **Input Dependencies**: tech-lead
- **Required Files**: docs/{backlog-keyword}/tech-spec.md
- **Output**: docs/{backlog-keyword}/openapi.yaml
- **Parallelizable**: Can run simultaneously with product-designer, be-test

### be-main
- **Input Dependencies**: be-test, be-spec
- **Required Files**:
  - tests/**/*.test.ts
  - docs/{backlog-keyword}/openapi.yaml
- **Output**: src/{controllers,services,repositories}/**

### fe-main
- **Input Dependencies**: product-designer, be-spec, be-main
- **Required Files**:
  - docs/{backlog-keyword}/design-spec.md (or Figma)
  - docs/{backlog-keyword}/openapi.yaml
- **Output**: src/{app,components,lib}/**
- **Special Notes**:
  - Starts sequentially from stories with completed designs
  - Adds integration code when API is completed

### qa-e2e
- **Input Dependencies**: fe-main, be-main
- **Required Files**:
  - docs/{backlog-keyword}/test-cases.md
  - A runnable application
- **Output**:
  - e2e/tests/{backlog-keyword}/*.spec.ts
  - docs/{backlog-keyword}/bug-reports/*.md

## Execution Order Examples

### Sequential Execution (Safe)

```
1. user-story-generator
2. wireframer
3. [PO Review]
4. tech-lead
5. qa-tc
6. product-designer
7. be-test
8. be-spec
9. be-main
10. fe-main
11. qa-e2e
12. [PO Final Review]
```

### Optimized Parallel Execution

```
Phase 1 (Sequential):
  1. user-story-generator
  2. wireframer
  3. [PO Review]

Phase 2 (Sequential):
  4. tech-lead
  5. qa-tc

Phase 3 (Parallel):
  6a. product-designer  ─┐
  6b. be-test          ─┼─ Simultaneous execution
  6c. be-spec          ─┘

Phase 4 (Sequential):
  7. be-main (after be-test + be-spec complete)
  8. fe-main (after designer + be-main complete)

Phase 5 (Sequential):
  9. qa-e2e
  10. Bug fix loop
  11. [PO Final Review]
```

## Bug Fix Feedback Loop

```
Bug found by qa-e2e
         │
    ┌────┴────┐
    ▼         ▼
 FE Bug    BE Bug
    │         │
    ▼         ▼
 fe-main   be-main
    │         │
    └────┬────┘
         ▼
     qa-e2e retest
         │
    Bugs remain? ──▶ Repeat
         │
         ▼ (No bugs)
    PO Final Review
```

## Rollback Scenarios

### Rollback from Phase 2 to Phase 1

```
Condition: Issue found in user stories during tech spec writing

1. Document the issue
2. Re-run user-story-generator
3. Re-run wireframer (affected parts)
4. PO re-review
5. Re-run tech-lead
```

### Rollback from Phase 4 to Phase 3

```
Condition: Spec change needed during API implementation

1. Document the changes
2. Update be-spec
3. Update be-test (if necessary)
4. Re-run be-main
```

## Status Tracking

### Workflow Status File

```yaml
# .workflow/status.yaml
project: my-project
backlog: account-feature
started_at: 2024-01-15T09:00:00Z
current_phase: 4
current_step: be-main

agents:
  user-story-generator:
    status: completed
    completed_at: 2024-01-15T09:30:00Z

  wireframer:
    status: completed
    completed_at: 2024-01-15T10:00:00Z

  po-review-1:
    status: approved
    completed_at: 2024-01-15T11:00:00Z

  tech-lead:
    status: completed
    completed_at: 2024-01-15T13:00:00Z

  qa-tc:
    status: completed
    completed_at: 2024-01-15T14:00:00Z

  product-designer:
    status: in_progress
    stories_done: 5
    stories_total: 8

  be-test:
    status: completed
    completed_at: 2024-01-15T15:00:00Z

  be-spec:
    status: completed
    completed_at: 2024-01-15T15:30:00Z

  be-main:
    status: in_progress
    tests_passing: 23
    tests_total: 30

  fe-main:
    status: pending

  qa-e2e:
    status: pending
```
