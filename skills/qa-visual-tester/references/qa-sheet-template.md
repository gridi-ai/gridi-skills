# QA Sheet Template

## QA Sheet

**Target URL**: {url}
**QA Scope**: {scope description}
**Created Date**: {date}
**Author**: QA Visual Tester

---

## Test Item Summary

| ID | Feature | Test Item | Priority | Type | Result |
|----|---------|-----------|----------|------|--------|
| QA-AUTH-001 | Login | Normal login | Critical | Positive | - |
| QA-AUTH-002 | Login | Wrong password error display | High | Negative | - |
| QA-AUTH-003 | Login | Empty field submission prevention | Medium | Boundary | - |

---

## Test Item Details

### QA-AUTH-001: Normal Login

**Priority**: Critical
**Type**: Positive

#### Given (Preconditions)
- The user has navigated to the login page (`/login`)
- A valid account exists

#### When (Execution)
- Enter a valid email in the email field
- Enter the correct password in the password field
- Click the login button

#### Then (Expected Result)
- The user is redirected to the dashboard page (`/dashboard`)
- The user's name is displayed on the screen

#### Result
- **Verdict**: -
- **Notes**: -

---

### QA-AUTH-002: Wrong Password Error Display

**Priority**: High
**Type**: Negative

#### Given (Preconditions)
- The user has navigated to the login page

#### When (Execution)
- Enter a valid email
- Enter a wrong password
- Click the login button

#### Then (Expected Result)
- An error message is displayed on the screen
- The user remains on the login page
- The password field is cleared

#### Result
- **Verdict**: -
- **Notes**: -

---

## Type Classification Criteria

| Type | Description |
|------|-------------|
| Positive | Verify normal behavior (Happy Path) |
| Negative | Verify error handling for abnormal input/state |
| Boundary | Verify extreme conditions such as boundary values, empty values, maximum values |
| UI/UX | Verify visual elements such as layout, responsiveness, accessibility |
| Security | Verify security-related items such as authentication, authorization, XSS |

## Priority Criteria

| Priority | Criteria |
|----------|----------|
| Critical | Core feature unavailable (login, payment, etc.) |
| High | Major feature affected |
| Medium | Partial feature limitation |
| Low | Usability/cosmetic issue |
