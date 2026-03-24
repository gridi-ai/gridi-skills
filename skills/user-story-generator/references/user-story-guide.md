# User Story Writing Guide

## Basic Structure

A user story consists of **Who, What, and Why**.

```
As a [user type], I can [feature/action]. (Because [purpose])
```

## Writing Principles

### 1. Conciseness
- Express clearly in a single sentence
- Long sentences are a sign of unorganized thinking
- Remove unnecessary modifiers

### 2. User-centric
- Use user-perspective language instead of technical terms
- Instead of "The system processes ~", use "The user can ~"

### 3. Why Can Be Omitted
- Omit if the purpose is self-evident from the feature
- Omit if the purpose was shared in a prior planning document

### 4. Hierarchical Structure
- **Depth 1 (Major Feature)**: Main feature categories
- **Depth 2 (Sub-feature)**: Detailed feature items
- Can be further subdivided by screen

## User Type Examples

| Type | Description |
|------|-------------|
| Unregistered User | A visitor who has not signed up |
| Registered User | A user who has completed sign-up |
| Logged-in User | A user currently in a logged-in state |
| Admin | A user with system administration privileges |
| Seller | A user who registers/sells products |
| Buyer | A user who purchases products |

## Good Examples vs Bad Examples

### Good Examples
- "A user can reset their password via email"
- "A seller can modify the price of a product"
- "A buyer can remove a product from the shopping cart"

### Bad Examples
- "The system handles user authentication" (system-centric)
- "Implement login feature" (feature listing)
- "A user can see a fast-loading page for a better experience" (too verbose)

## Story ID Rules

```
US-{sequence}: {Story Title}
```

- Sequence starts from 001
- Group by major feature and assign sequential numbers
