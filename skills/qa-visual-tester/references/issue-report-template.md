# Issue Report Template

## ISSUE-{Number}: {Issue Title}

**Severity**: Critical / High / Medium / Low
**Related TC**: QA-{feature-code}-{sequence}
**Date Found**: {timestamp}

### Steps to Reproduce

1. Navigate to {page URL}
2. {User action 1}
3. {User action 2}
4. {Point when issue occurs}

### Expected Result

- {What should happen normally}

### Actual Result

- {What actually occurred}

### Screenshots

| Order | Description | File |
|-------|-------------|------|
| 1 | Screen before action | `screenshot-01-before-action.png` |
| 2 | Screen after action (issue occurred) | `screenshot-02-after-action.png` |

### Console Errors (If Applicable)

```
{Error logs confirmed via browser_console_messages}
```

### Network Errors (If Applicable)

```
{Failed requests confirmed via browser_network_requests}
```

### Environment Information

- **Browser**: Chromium (Playwright MCP)
- **Screen Size**: {width}x{height}
- **URL**: {test URL}

### Severity Justification

{Brief explanation of why this severity was assigned}
