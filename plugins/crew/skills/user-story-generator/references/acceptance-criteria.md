# Acceptance Criteria Guide

## Definition

Acceptance criteria are specific conditions used to determine whether a user story has been completed.

## Writing Format

```markdown
**Acceptance Criteria**:
- [ ] [Condition 1]
- [ ] [Condition 2]
- [ ] [Condition 3]
```

## Writing Principles

### 1. Measurable
- Instead of "fast", use "within 3 seconds"
- Instead of "appropriate", use "within 100 characters"

### 2. Verifiable
- Conditions that can be confirmed through testing
- Avoid ambiguous expressions

### 3. Independent
- Each condition can be verified individually
- Does not depend on other conditions

## Examples by Category

### Input Validation
```markdown
- [ ] Verify email format is correct
- [ ] Password is at least 8 characters
- [ ] Show error when required fields are empty
```

### Permissions/Security
```markdown
- [ ] Users who are not logged in cannot access
- [ ] Only own data can be modified
- [ ] Only admins can delete
```

### UI/UX
```markdown
- [ ] Show confirmation message on success
- [ ] Show error message on failure
- [ ] Show loading indicator during processing
```

### Data
```markdown
- [ ] Saved data is immediately reflected in the list
- [ ] Related data is also deleted on deletion
- [ ] Duplicate data registration is not allowed
```

## When to Include

Include acceptance criteria only when the user explicitly requests them:
- "Include acceptance criteria too"
- "Write ACs as well"
- "Add test conditions too"
