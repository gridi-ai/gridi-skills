# Subagent Execution Guide

## Overview

The workflow orchestrator uses the `Task` tool to run each skill as an independent subagent.
Skills serve as "instruction manuals," and subagents perform work following those instructions.

## Project Initialization (First Run)

Before starting any workflow, verify the existence of `crew-config.json`:

```
crew-config.json exists?
     │
     ├── NO → Run project-init
     │         Task(
     │           subagent_type: "general-purpose",
     │           prompt: """
     │             Refer to ${CREW_SKILLS}/project-init/SKILL.md and perform the task.
     │             Analyze the project and generate crew-config.json.
     │           """,
     │           description: "Project initialization"
     │         )
     │
     └── YES → Read configuration and proceed to next step
```

## Common Subagent Prompt Structure

Include the following in all subagent prompts:

```
Task(
  subagent_type: "general-purpose",
  prompt: """
    Refer to ${CREW_SKILLS}/{skill-name}/SKILL.md and perform the task.

    ## Project Configuration
    Read the crew-config.json file and operate according to the project settings.

    ## Project Information
    - Project root: {project path}
    - Backlog keyword: {backlog-keyword}

    ## Input Files
    {Input file list}

    ## Expected Output
    {Output file path}
  """,
  description: "{skill-name} execution"
)
```

## Input Classification and Workflow Selection

Select one of two workflows based on user input:

```
User Input
     │
     ▼
┌─────────────────────────────────┐
│  Input Classification            │
│  - "Build me a shopping mall" → Comprehensive │
│  - "Add login feature" → Single  │
└─────────────────────────────────┘
     │
     ├── Comprehensive Request ──▶ Phase -1 (Backlog Decomposition) → Sequential Execution
     │
     └── Single Backlog ──▶ Start from Phase 0
```

### Phase -1: Backlog Decomposition (For Comprehensive Requests)

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: """
    Refer to ${CREW_SKILLS}/backlog-decomposer/SKILL.md and perform the task.

    ## User Request
    {Original user request}

    ## Output
    docs/project-backlog.md

    ## Instructions
    1. Analyze the request and derive the feature list
    2. Determine MVP scope
    3. Decompose and prioritize backlogs
    4. Include dependency diagram
  """,
  description: "Backlog decomposition"
)
```

## Execution Patterns

### Basic Pattern: Task Tool Invocation

```
Task(
  subagent_type: "general-purpose",
  prompt: """
    Refer to ${CREW_SKILLS}/{skill-name}/SKILL.md and perform the task.

    Input file: docs/{backlog-keyword}/{input-file}.md
    Output file: docs/{backlog-keyword}/{output-file}.md

    Backlog keyword: {backlog-keyword}
  """,
  description: "{skill-name} execution"
)
```

### Sequential Execution Example

```python
# Phase 1: Planning
task1 = Task(
  subagent_type="general-purpose",
  prompt="""
    Refer to ${CREW_SKILLS}/user-story-generator/SKILL.md and
    write user stories for the following backlog.

    Backlog: {backlog content}
    Output: docs/{backlog-keyword}/user-stories.md
  """,
  description="User story generation"
)

# Wait for task1 to complete
task2 = Task(
  subagent_type="general-purpose",
  prompt="""
    Refer to ${CREW_SKILLS}/wireframer/SKILL.md and
    create wireframes based on the user stories.

    Input: docs/{backlog-keyword}/user-stories.md
    Output: docs/{backlog-keyword}/wireframes.md
  """,
  description="Wireframe generation"
)
```

### Parallel Execution Example (Phase 3)

```python
# Call 3 Tasks simultaneously (in a single message)
Task(
  subagent_type="general-purpose",
  prompt="Refer to ${CREW_SKILLS}/product-designer/SKILL.md and perform design work...",
  description="Design work",
  run_in_background=True
)

Task(
  subagent_type="general-purpose",
  prompt="Refer to ${CREW_SKILLS}/be-test/SKILL.md and write test code...",
  description="BE test writing",
  run_in_background=True
)

Task(
  subagent_type="general-purpose",
  prompt="Refer to ${CREW_SKILLS}/be-spec/SKILL.md and write OpenAPI spec...",
  description="API spec writing",
  run_in_background=True
)

# Collect results with TaskOutput
```

## Full Workflow Execution Flow

```
Orchestrator Start
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: Planning                                            │
├─────────────────────────────────────────────────────────────┤
│ Task(user-story-generator) → Wait for completion             │
│ Task(wireframer) → Wait for completion                       │
│ [PO Review Request] → Wait for approval                      │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 2: Design                                              │
├─────────────────────────────────────────────────────────────┤
│ Task(tech-lead) → Wait for completion                        │
│ Task(qa-tc) → Wait for completion                            │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 3: Implementation Preparation (Parallel)               │
├─────────────────────────────────────────────────────────────┤
│ Task(product-designer, background=true)  ─┐                  │
│ Task(be-test, background=true)           ─┼─ Simultaneous    │
│ Task(be-spec, background=true)           ─┘                  │
│ TaskOutput() × 3 → Wait for all tasks to complete            │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 4: Implementation                                      │
├─────────────────────────────────────────────────────────────┤
│ Task(be-main) → Wait for completion                          │
│ Task(fe-main) → Wait for completion                          │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 5: QA                                                  │
├─────────────────────────────────────────────────────────────┤
│ Task(qa-e2e) → Wait for completion                           │
│ If bugs found → Task(be-main/fe-main) → Task(qa-e2e) repeat │
│ [PO Final Review Request]                                    │
└─────────────────────────────────────────────────────────────┘
```

## Prompt Templates

### Skill Execution Base Template

```
Refer to the following skill and perform the task.

## Skill Location
${CREW_SKILLS}/{skill-name}/SKILL.md

## Project Information
- Project root: {project path}
- Backlog keyword: {backlog-keyword}

## Input Files
{Input file list}

## Expected Output
{Output file path}

## Additional Instructions
{Context-specific additional instructions}
```

### Bug Fix Template

```
Fix the bugs found by QA-E2E.

## Bug Report
docs/{backlog-keyword}/bug-reports/{bug-id}.md

## Fix Target
- FE bugs: Refer to ${CREW_SKILLS}/fe-main/SKILL.md
- BE bugs: Refer to ${CREW_SKILLS}/be-main/SKILL.md

## After Fixing
Run tests to verify that the bugs have been resolved
```

## Error Handling

### When Skill Execution Fails

1. Record the error details
2. Check if rollback is possible
3. Re-run the previous step if necessary
4. Report the issue to the PO

### When Dependency Files Are Missing

```
Before Task execution, verify file existence:
- Read(docs/{backlog-keyword}/{required-file}.md)
- If the file is missing, run the corresponding skill first
```

## State Management

Update the status file after each Task completion:

```yaml
# .workflow/status.yaml
agents:
  {skill-name}:
    status: completed | in_progress | failed
    started_at: timestamp
    completed_at: timestamp
    output_files:
      - path/to/output.md
    error: null | "Error message"
```

## Model Selection Guide

| Skill | Recommended Model | Reason |
|-------|-------------------|--------|
| user-story-generator | sonnet | Requires creative writing |
| wireframer | haiku | Structured ASCII output |
| tech-lead | sonnet/opus | Architecture design complexity |
| qa-tc | haiku | Pattern-based test cases |
| product-designer | sonnet | MCP tool utilization |
| be-test | haiku | Pattern-based code generation |
| be-spec | haiku | Schema-based generation |
| be-main | sonnet | Complex business logic |
| fe-main | sonnet | UI/UX implementation complexity |
| qa-e2e | haiku | Pattern-based tests |

```python
# Model specification example
Task(
  subagent_type="general-purpose",
  model="haiku",  # For fast tasks
  prompt="...",
  description="..."
)
```
