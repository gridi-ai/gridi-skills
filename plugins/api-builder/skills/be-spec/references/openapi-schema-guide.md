# OpenAPI Schema Authoring Guide

## Data Types

### Basic Types

```yaml
# String
name:
  type: string
  minLength: 1
  maxLength: 100

# Number
age:
  type: integer
  minimum: 0
  maximum: 150

price:
  type: number
  format: double
  minimum: 0

# Boolean
isActive:
  type: boolean
  default: true

# Array
tags:
  type: array
  items:
    type: string
  minItems: 1
  maxItems: 10
  uniqueItems: true
```

### String Formats

```yaml
# Email
email:
  type: string
  format: email

# URL
website:
  type: string
  format: uri

# UUID
id:
  type: string
  format: uuid

# Date/Time
createdAt:
  type: string
  format: date-time  # 2024-01-15T09:30:00Z

birthDate:
  type: string
  format: date       # 2024-01-15

# Password (masked)
password:
  type: string
  format: password

# Binary
file:
  type: string
  format: binary
```

### Pattern Validation

```yaml
# Regex pattern
phone:
  type: string
  pattern: '^\\+?[1-9]\\d{1,14}$'
  description: Phone number in E.164 format

# Korean phone number
koreanPhone:
  type: string
  pattern: '^01[016789]-?\\d{3,4}-?\\d{4}$'
```

## Object Definitions

### Required/Optional Fields

```yaml
User:
  type: object
  required:
    - email
    - password
  properties:
    email:
      type: string
      format: email
    password:
      type: string
      format: password
    nickname:
      type: string
      description: Optional field
```

### Restrict Additional Properties

```yaml
# Allow only defined properties
StrictObject:
  type: object
  additionalProperties: false
  properties:
    name:
      type: string

# Specify additional property types
FlexibleObject:
  type: object
  additionalProperties:
    type: string
```

### Nullable

```yaml
deletedAt:
  type: string
  format: date-time
  nullable: true
  description: Deletion time (null if not deleted)
```

## Advanced Patterns

### allOf (Composition)

```yaml
# Base user + profile
UserWithProfile:
  allOf:
    - $ref: '#/components/schemas/User'
    - type: object
      properties:
        profile:
          type: object
          properties:
            bio:
              type: string
            avatar:
              type: string
              format: uri
```

### oneOf (Choose One)

```yaml
# Payment method (choose one only)
PaymentMethod:
  oneOf:
    - $ref: '#/components/schemas/CreditCard'
    - $ref: '#/components/schemas/BankTransfer'
    - $ref: '#/components/schemas/VirtualAccount'
```

### anyOf (Combinable)

```yaml
# Multiple search filter combinations
SearchFilter:
  anyOf:
    - $ref: '#/components/schemas/DateFilter'
    - $ref: '#/components/schemas/CategoryFilter'
    - $ref: '#/components/schemas/PriceFilter'
```

### discriminator (Type Distinction)

```yaml
Pet:
  type: object
  required:
    - petType
  properties:
    petType:
      type: string
  discriminator:
    propertyName: petType
    mapping:
      dog: '#/components/schemas/Dog'
      cat: '#/components/schemas/Cat'

Dog:
  allOf:
    - $ref: '#/components/schemas/Pet'
    - type: object
      properties:
        breed:
          type: string

Cat:
  allOf:
    - $ref: '#/components/schemas/Pet'
    - type: object
      properties:
        color:
          type: string
```

## Request Schemas

### Query Parameters

```yaml
parameters:
  - name: page
    in: query
    schema:
      type: integer
      minimum: 1
      default: 1
  - name: limit
    in: query
    schema:
      type: integer
      minimum: 1
      maximum: 100
      default: 20
  - name: sort
    in: query
    schema:
      type: string
      enum: [createdAt, -createdAt, name, -name]
      default: -createdAt
```

### Path Parameters

```yaml
parameters:
  - name: userId
    in: path
    required: true
    schema:
      type: string
      format: uuid
    description: User ID
```

### Request Body

```yaml
requestBody:
  required: true
  content:
    application/json:
      schema:
        $ref: '#/components/schemas/CreateUserRequest'
      examples:
        basic:
          summary: Basic example
          value:
            email: user@example.com
            password: Test1234!
        withProfile:
          summary: With profile
          value:
            email: user@example.com
            password: Test1234!
            profile:
              nickname: John
```

### File Upload

```yaml
requestBody:
  content:
    multipart/form-data:
      schema:
        type: object
        required:
          - file
        properties:
          file:
            type: string
            format: binary
          description:
            type: string
      encoding:
        file:
          contentType: image/png, image/jpeg
```

## Response Schemas

### Single Resource

```yaml
responses:
  '200':
    description: Success
    content:
      application/json:
        schema:
          type: object
          properties:
            data:
              $ref: '#/components/schemas/User'
```

### List (Pagination)

```yaml
responses:
  '200':
    description: Success
    content:
      application/json:
        schema:
          type: object
          properties:
            data:
              type: array
              items:
                $ref: '#/components/schemas/User'
            pagination:
              type: object
              properties:
                page:
                  type: integer
                limit:
                  type: integer
                total:
                  type: integer
                totalPages:
                  type: integer
```

### Error Response

```yaml
responses:
  '400':
    description: Bad request
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/Error'
        examples:
          validation:
            summary: Validation failure
            value:
              error:
                code: VALIDATION_ERROR
                message: The input values are invalid.
                details:
                  - field: email
                    message: Please enter a valid email address.
```

## Common Components

### Reusable Parameters

```yaml
components:
  parameters:
    PageParam:
      name: page
      in: query
      schema:
        type: integer
        default: 1

    LimitParam:
      name: limit
      in: query
      schema:
        type: integer
        default: 20

# Usage
paths:
  /users:
    get:
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
```

### Reusable Headers

```yaml
components:
  headers:
    X-Total-Count:
      description: Total count
      schema:
        type: integer

# Usage
responses:
  '200':
    headers:
      X-Total-Count:
        $ref: '#/components/headers/X-Total-Count'
```
