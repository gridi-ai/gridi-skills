# Bug Report Template

## Basic Template

```markdown
# BUG-{ID}: {Bug Title}

## Basic Information

| Item | Details |
|------|---------|
| Bug ID | BUG-{ID} |
| Severity | Critical / High / Medium / Low |
| Priority | P0 / P1 / P2 / P3 |
| Status | Open / In Progress / Resolved / Closed |
| Found By | {Name} |
| Date Found | {YYYY-MM-DD} |
| Assignee | {Name} |
| Related TC | TC-{ID} |

## Environment

| Item | Details |
|------|---------|
| Browser | Chrome 120 / Firefox 121 / Safari 17 |
| OS | Windows 11 / macOS 14 / Ubuntu 22 |
| Screen Size | 1920x1080 / 1440x900 / 375x667 |
| App Version | v1.2.3 |
| Environment | Production / Staging / Development |

## Steps to Reproduce

### Preconditions
- {Condition 1}
- {Condition 2}

### Steps
1. {Step 1}
2. {Step 2}
3. {Step 3}

## Results

### Expected Result
{Expected behavior}

### Actual Result
{Actual behavior observed}

## Attachments

### Screenshots
![Bug Screenshot](./screenshots/bug-{id}.png)

### Video
[Bug Reproduction Video](./videos/bug-{id}.webm)

### Console Logs
```
{Console error messages}
```

### Network Logs
```
{Failed API requests/responses}
```

## Additional Information

### Reproduction Frequency
- [ ] Always reproducible
- [ ] Frequently reproducible (80% or more)
- [ ] Sometimes reproducible (around 50%)
- [ ] Rarely reproducible (30% or less)
- [ ] Reproduced only once

### Impact Scope
{Features/users affected by this bug}

### Workaround
{Describe temporary workaround if available}

### Related Issues
- #{Related issue number}

---

## Resolution Record

### Root Cause Analysis
{Root cause of the bug}

### Fix History
- PR: #{PR number}
- Commit: {commit hash}

### Verification Result
- [ ] Fix confirmed
- [ ] Regression test passed
```

## Severity Criteria

| Severity | Description | Examples |
|----------|-------------|----------|
| Critical | Service unavailable, data loss | Cannot log in, payment failure, data deleted |
| High | Major feature unavailable, no workaround | Sign-up failure, search unavailable |
| Medium | Partial feature limitation, workaround available | Sorting error, filter not working |
| Low | Usability issue, cosmetic problem | Typo, UI alignment, color error |

## Priority Criteria

| Priority | Description | Resolution Deadline |
|----------|-------------|-------------------|
| P0 | Immediate fix required | Within 24 hours |
| P1 | Quick fix required | Before next deployment |
| P2 | Normal fix | Next sprint |
| P3 | Low priority | Backlog |

## Bug Classification

### Functional Bugs
- Feature behaves differently from spec
- Feature cannot be performed due to errors

### UI/UX Bugs
- Broken layout
- Responsive issues
- Mismatch with design spec

### Performance Bugs
- Slow loading
- Memory leaks
- High CPU usage

### Security Bugs
- Authentication/authorization bypass
- Data exposure
- XSS/CSRF vulnerabilities

### Compatibility Bugs
- Occurs only in specific browsers
- Occurs only in specific OS
- Occurs only on specific devices

## Screenshot Guide

### Required Capture Items
1. Full screen showing the bug
2. Zoomed-in error message
3. Developer tools Console tab
4. Developer tools Network tab (for API errors)

### Annotation Method
- Mark problem area with a red box
- Point to the problem with arrows
- Number items when necessary

## Video Recording Guide

### Recording Contents
1. Initial screen state
2. Bug reproduction steps (slowly)
3. Moment the bug occurs
4. Error messages (if any)
5. Console logs (with developer tools open)

### File Format
- Format: WebM or MP4
- Maximum size: 50MB
- Resolution: 1080p or lower
