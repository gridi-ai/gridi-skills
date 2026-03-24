# code-review

Backend and frontend code review with confidence-based filtering. Only reports high-severity, high-confidence issues that truly matter.

## Installation

```bash
/plugin marketplace add gridi-ai/gridi-skills
/plugin install code-review@gridi-skills
```

## Skills

| Skill | Description |
|-------|-------------|
| `be-lead` | Backend architecture, security, and performance review |
| `fe-lead` | Frontend component quality, performance, and accessibility review |

## Features

- Architecture violation detection
- Security vulnerability scanning
- Performance anti-pattern identification
- Confidence-based filtering — only reports issues worth fixing
- Checklists for architecture, security, components, and performance

## Usage

```
/code-review:be-lead Review the latest changes
/code-review:fe-lead Review the frontend components
```

## What It Checks

### Backend (be-lead)

- Layered architecture compliance
- SQL injection and authentication vulnerabilities
- N+1 query detection
- Error handling patterns
- API contract consistency

### Frontend (fe-lead)

- Component structure and reusability
- Unnecessary re-renders
- Bundle size impact
- Accessibility (a11y) compliance
- State management patterns
