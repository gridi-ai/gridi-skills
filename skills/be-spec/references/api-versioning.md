# API Versioning Guide

## Versioning Strategies

### 1. URL Path Versioning (Recommended)

```
https://api.example.com/v1/users
https://api.example.com/v2/users
```

**Advantages:**
- Clear and intuitive
- Can be tested directly in the browser
- Cache-friendly

**OpenAPI Configuration:**
```yaml
servers:
  - url: https://api.example.com/v1
    description: Version 1
  - url: https://api.example.com/v2
    description: Version 2
```

### 2. Header Versioning

```
GET /users
Accept: application/vnd.example.v1+json
```

**OpenAPI Configuration:**
```yaml
components:
  parameters:
    ApiVersion:
      name: Accept
      in: header
      required: true
      schema:
        type: string
        enum:
          - application/vnd.example.v1+json
          - application/vnd.example.v2+json
```

### 3. Query Parameter Versioning

```
GET /users?version=1
```

**OpenAPI Configuration:**
```yaml
parameters:
  - name: version
    in: query
    schema:
      type: integer
      enum: [1, 2]
      default: 1
```

## When to Upgrade Versions

### Major Change - New Version Required

- Adding required fields
- Removing fields
- Changing field types
- Changing response structure
- Changing authentication method
- Changing error code system

### Minor Change - Keep Existing Version

- Adding optional fields
- Adding new endpoints
- Adding new fields to responses
- Updating descriptions/documentation

## Maintaining Backward Compatibility

### Add as Optional Fields

```yaml
# Before
User:
  type: object
  required:
    - email
  properties:
    email:
      type: string

# After (compatible)
User:
  type: object
  required:
    - email
  properties:
    email:
      type: string
    nickname:  # Added as optional field
      type: string
```

### Provide Default Values

```yaml
status:
  type: string
  enum: [active, inactive, pending]
  default: active  # Backward compatible with existing clients
```

### Maintain Aliases

```yaml
# When renaming a field
username:
  type: string
  deprecated: true
  description: Use 'nickname' instead

nickname:
  type: string
```

## Deprecated Handling

### Endpoint Deprecated

```yaml
/users/{id}:
  get:
    deprecated: true
    summary: "[Deprecated] Get user"
    description: |
      **This API will be removed on 2024-06-01.**
      Please use `/v2/users/{id}` instead.
```

### Field Deprecated

```yaml
User:
  type: object
  properties:
    fullName:
      type: string
      deprecated: true
      description: "Deprecated: Use firstName and lastName instead"
    firstName:
      type: string
    lastName:
      type: string
```

### Warning via Response Headers

```yaml
responses:
  '200':
    headers:
      Deprecation:
        schema:
          type: string
        example: "Sun, 01 Jun 2024 00:00:00 GMT"
      Sunset:
        schema:
          type: string
        example: "Sun, 01 Sep 2024 00:00:00 GMT"
```

## Version-Specific Documentation Management

### File Structure

```
docs/api/
├── v1/
│   ├── openapi.yaml
│   ├── paths/
│   └── schemas/
└── v2/
    ├── openapi.yaml
    ├── paths/
    └── schemas/
```

### Separate Common Schemas

```
docs/api/
├── common/
│   ├── schemas/
│   │   ├── pagination.yaml
│   │   └── error.yaml
│   └── parameters/
│       └── common.yaml
├── v1/
│   └── openapi.yaml  # $ref: '../common/...'
└── v2/
    └── openapi.yaml
```

## Migration Guide

### Document Differences Between Versions

```markdown
# V1 → V2 Migration Guide

## Breaking Changes

### 1. User Response Structure Changed

**V1:**
```json
{
  "id": "...",
  "email": "..."
}
```

**V2:**
```json
{
  "data": {
    "id": "...",
    "email": "..."
  }
}
```

### 2. Error Response Changed

**V1:**
```json
{
  "error": "message"
}
```

**V2:**
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "message"
  }
}
```

## Migration Steps

1. Install the new SDK version
2. Update response parsing logic
3. Fix error handling
4. Run tests
```

## Version Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│ Version Lifecycle                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  V1: ████████████████████░░░░░░░░ (Active → Deprecated) │
│  V2: ░░░░░░░░████████████████████ (Active)              │
│                                                         │
│  ─────┼─────────┼─────────┼─────────┼───────────────▶   │
│       V2        V1        V1        V1                  │
│     Release   Deprecated  Sunset   Removed              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Typical Lifecycle

- **Active**: Currently recommended version
- **Deprecated**: 6-month grace period
- **Sunset**: Last day of support
- **Removed**: Fully removed
