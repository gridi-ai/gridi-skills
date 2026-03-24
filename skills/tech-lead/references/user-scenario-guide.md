# User Scenario Writing Guide

## Definition

A user scenario is a document that describes step-by-step how a user interacts with the system to achieve a specific goal.

## Scenario Components

### 1. Scenario ID and Title
```markdown
### SC-001: Email Sign-up
```

### 2. Preconditions
Conditions that must be met before the scenario begins
```markdown
**Preconditions**:
- The user has navigated to the sign-up page
- The user is not logged in
```

### 3. Main Flow
User-system interaction along the normal path
```markdown
**Main Flow**:
1. The user enters an email in the email input field
2. The system validates the email format in real-time
3. The user enters a password
4. The system displays the password strength
5. The user enters the password confirmation
6. The system verifies that the two passwords match
7. The user clicks the 'Sign Up' button
8. The system processes the sign-up
9. The system sends a verification email
10. The system redirects to the email verification guide page
```

### 4. Alternative Flow
Valid alternatives that branch off from the main flow
```markdown
**Alternative Flow**:
- 3a. Select social sign-up:
  1. The user clicks the 'Sign Up with Google' button
  2. The system redirects to the Google OAuth page
  3. The user authenticates with their Google account
  4. The system receives the callback and completes sign-up
```

### 5. Exception Flow
Error situations and system responses
```markdown
**Exception Flow**:
- E1. Duplicate email:
  - Condition: The entered email is already registered
  - System response: Display error "This email is already registered"
  - User action: Enter a different email or attempt to log in

- E2. Password mismatch:
  - Condition: Password and password confirmation do not match
  - System response: Display error "Passwords do not match"
  - User action: Re-enter password

- E3. Network error:
  - Condition: API call failure
  - System response: Display "A temporary error occurred. Please try again"
  - User action: Click retry button
```

### 6. Postconditions
System state after scenario completion
```markdown
**Postconditions**:
- A user account has been created in the database
- Account status is 'Email Unverified'
- A verification email has been sent
```

## Scenario Types

### 1. Happy Path Scenario
The ideal flow where everything works correctly

### 2. Edge Case Scenario
System behavior under boundary conditions
- Maximum/minimum input values
- Empty data
- Special characters

### 3. Error Scenario
Expected error situations
- Validation failure
- No permission
- Resource not found

### 4. Security Scenario
Security-related test cases
- Unauthenticated access
- Privilege escalation attempt
- Malicious input

## Scenario to User Story Mapping

```markdown
| Scenario ID | User Story | Description |
|-------------|------------|-------------|
| SC-001 | US-001 | Email sign-up |
| SC-002 | US-001 | Sign-up validation |
| SC-003 | US-002 | Social sign-up |
```

## Checklist

Items to verify when writing scenarios:
- [ ] Are all user stories covered by scenarios?
- [ ] Is the main flow clear?
- [ ] Are exception cases sufficiently defined?
- [ ] Are preconditions/postconditions clear?
- [ ] Can scenarios be converted to test cases?
