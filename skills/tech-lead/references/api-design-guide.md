# API Design Guide

## RESTful API Principles

### 1. Resource Naming

```
Good examples:
GET /api/v1/users
GET /api/v1/users/:id
GET /api/v1/users/:id/orders

Bad examples:
GET /api/v1/getUsers
GET /api/v1/user/get/:id
```

### 2. HTTP Methods

| Method | Purpose | Success Code |
|--------|---------|-------------|
| GET | Retrieve | 200 OK |
| POST | Create | 201 Created |
| PUT | Full update | 200 OK |
| PATCH | Partial update | 200 OK |
| DELETE | Delete | 204 No Content |

### 3. Status Codes

#### Success (2xx)
- 200: Success
- 201: Created
- 204: No Content (delete success)

#### Client Error (4xx)
- 400: Bad Request
- 401: Authentication required
- 403: Forbidden (no permission)
- 404: Resource not found
- 409: Conflict (duplicate)
- 422: Unprocessable Entity (validation failure)

#### Server Error (5xx)
- 500: Internal Server Error
- 503: Service Unavailable

### 4. Response Format

#### Success Response
```json
{
  "data": {
    "id": "uuid",
    "email": "user@example.com"
  }
}
```

#### List Response (Pagination)
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

#### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The email format is invalid.",
    "details": [
      {
        "field": "email",
        "message": "Please enter a valid email address."
      }
    ]
  }
}
```

### 5. Versioning

```
/api/v1/users
/api/v2/users
```

### 6. Filtering/Sorting/Pagination

```
GET /api/v1/users?status=active&sort=-createdAt&page=1&limit=20
```

- Filter: `?status=active`
- Sort: `?sort=-createdAt` (- means descending)
- Pagination: `?page=1&limit=20`

## Authentication/Authorization

### JWT Token

```
Authorization: Bearer {token}
```

### Token Structure
- Access Token: Short expiry (15 min to 1 hour)
- Refresh Token: Long expiry (7 to 30 days)

## API Documentation

Document in OpenAPI 3.0 format:

```yaml
openapi: 3.0.0
info:
  title: API Specification
  version: 1.0.0

paths:
  /api/v1/users:
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: Created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
```
