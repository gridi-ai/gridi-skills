# Test Case Template

## Basic Template

```markdown
## TC-{ID}: {Test Case Title}

**Priority**: Critical | High | Medium | Low
**Test Type**: Positive | Negative | Boundary | Security
**Related Story**: US-XXX
**Automated**: Yes | No

### Preconditions
- [System/data state]
- [Required settings]

### Test Data
| Field | Value | Notes |
|-------|-------|-------|
| field1 | value1 | |
| field2 | value2 | |

### Test Steps
| Step | Action | Expected Result |
|------|--------|----------------|
| 1 | [Action description] | [Expected result] |
| 2 | [Action description] | [Expected result] |

### Expected Result
- [Final expected result 1]
- [Final expected result 2]

### Postconditions
- [System state after test]
- [Data that needs cleanup]

### Notes
- [Additional reference information]
```

## API Test Template

```markdown
## TC-API-{ID}: {API Test Case Title}

**Endpoint**: `{METHOD} {path}`
**Priority**: High
**Test Type**: Positive

### Request

**Headers**:
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

**Body**:
```json
{
  "field1": "value1"
}
```

### Response

**Status Code**: 200 OK

**Body**:
```json
{
  "data": {
    "id": "uuid",
    "field1": "value1"
  }
}
```

### Verification Items
- [ ] Status code check
- [ ] Response schema validation
- [ ] Required fields existence check
- [ ] Database state check
```

## UI Test Template

```markdown
## TC-UI-{ID}: {UI Test Case Title}

**Page**: {Page name}
**Browser**: Chrome, Firefox, Safari
**Device**: Desktop, Mobile

### Test Steps

| Step | Action | Expected Result | Screenshot |
|------|--------|----------------|------------|
| 1 | Navigate to URL | Page loaded | [Capture needed] |
| 2 | Click button | Modal displayed | [Capture needed] |

### Verification Items
- [ ] Layout is correct
- [ ] Responsive behavior
- [ ] Accessibility (keyboard navigation)
- [ ] Loading state displayed
```

## Checklist Template

```markdown
## {Feature Name} Test Checklist

### Functional Tests
- [ ] TC-001: Normal case
- [ ] TC-002: Error case

### Validation
- [ ] TC-010: Required field validation
- [ ] TC-011: Format validation
- [ ] TC-012: Boundary value validation

### Security Tests
- [ ] TC-020: Authentication verification
- [ ] TC-021: Authorization verification

### UI/UX Tests
- [ ] TC-030: Responsive test
- [ ] TC-031: Loading state test
- [ ] TC-032: Error state display
```

## Bug Report Template

```markdown
## BUG-{ID}: {Bug Title}

**Severity**: Critical | High | Medium | Low
**Version Found**: v1.0.0
**Related TC**: TC-XXX

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Result
[Expected behavior]

### Actual Result
[Actual behavior observed]

### Environment
- OS:
- Browser:
- Device:

### Attachments
- [Screenshots/log files]
```
