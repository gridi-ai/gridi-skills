# Backend Security Review Checklist

## Authentication

### JWT Tokens
- [ ] Is the Access Token expiration time appropriate? (15 minutes or less recommended)
- [ ] Is the Refresh Token stored securely? (httpOnly cookie)
- [ ] Is the algorithm explicitly specified during token verification?
- [ ] Is the JWT Secret loaded from environment variables? (Hardcoding prohibited)
- [ ] Is token blacklisting/logout handling implemented?

```typescript
// 🔴 Algorithm not specified → Algorithm Confusion Attack possible
jwt.verify(token, secret);

// ✅ Algorithm explicitly specified
jwt.verify(token, secret, { algorithms: ['HS256'] });
```

### Passwords
- [ ] Is hashing done with bcrypt/argon2? (MD5, SHA prohibited)
- [ ] Are salt rounds sufficient? (bcrypt 12 or higher)
- [ ] Is password strength validation also performed server-side?
- [ ] Do password-related error messages avoid information leakage?

```typescript
// 🔴 Information-leaking error messages
"No user found with this email" // Reveals email existence
"Password does not match" // Confirms account exists

// ✅ Safe error messages
"Email or password is incorrect"
```

## Authorization

### Access Control
- [ ] Is authentication middleware applied to all endpoints?
- [ ] Are public endpoints explicitly marked?
- [ ] Are RBAC/ABAC permission checks properly implemented?
- [ ] Is resource ownership verification performed? (IDOR prevention)

```typescript
// 🔴 IDOR (Insecure Direct Object Reference)
@Get('/users/:id/profile')
async getProfile(@Param('id') id: string) {
  return this.userService.getProfile(id);
  // If another user's ID is entered, their profile can be retrieved
}

// ✅ Ownership verification
@Get('/users/:id/profile')
async getProfile(@Param('id') id: string, @CurrentUser() user: User) {
  if (id !== user.id && !user.isAdmin) {
    throw new ForbiddenError();
  }
  return this.userService.getProfile(id);
}
```

### Horizontal/Vertical Privilege Escalation
- [ ] Can regular users not access admin functions? (Vertical)
- [ ] Can users not access other users' resources? (Horizontal)
- [ ] Can privileges not be escalated through API parameter manipulation?

## Input Validation

### General Principles
- [ ] Is all input validated server-side? (Do not rely on client validation)
- [ ] Is a validation library such as Zod/class-validator being used?
- [ ] Is a request size limit configured? (body-parser limit)
- [ ] Are file uploads validated for type and size?

### Injection Prevention
- [ ] **SQL Injection**: Is ORM or Parameterized Query being used?
- [ ] **NoSQL Injection**: Is user input not passed directly into MongoDB queries?
- [ ] **Command Injection**: Is user input not passed directly to `exec`, `spawn`?
- [ ] **Path Traversal**: Is path validation performed when using user input in file paths?
- [ ] **SSRF**: Does the server not make requests to user-provided URLs?

```typescript
// 🔴 Command Injection
const output = execSync(`convert ${userFilename} output.png`);

// ✅ Pass arguments as an array
const output = execFileSync('convert', [userFilename, 'output.png']);
```

### XSS Prevention
- [ ] Is user input sanitized before being rendered as HTML?
- [ ] Is the Content-Type header properly set?
- [ ] Is a CSP (Content Security Policy) header configured?

## Sensitive Data

### Data Protection
- [ ] Are passwords, tokens, and API keys excluded from responses?
- [ ] Is sensitive information masked in logs?
- [ ] Are internal implementation details not exposed in error responses?
- [ ] Is sensitive information stored in environment variables? (Code hardcoding prohibited)

```typescript
// 🔴 Password included in response
return user; // password field included

// ✅ Convert to response DTO
return {
  id: user.id,
  email: user.email,
  name: user.name,
  // password excluded
};
```

### Environment Variables
- [ ] Is the `.env` file included in `.gitignore`?
- [ ] Does `.env.example` not contain actual secrets?
- [ ] Is environment variable validation performed at app startup? (Fail fast on missing values)

## Security Headers and Configuration

### HTTP Security
- [ ] Is Helmet (or equivalent security headers) applied?
- [ ] Does CORS specify only allowed origins? (`*` usage prohibited)
- [ ] Is HTTPS enforced?
- [ ] Is the `Strict-Transport-Security` header configured?

### Rate Limiting
- [ ] Is global Rate Limiting configured?
- [ ] Is enhanced Rate Limiting applied to sensitive endpoints like login?
- [ ] Has dual limiting by IP + user been considered?

## Mass Assignment

```typescript
// 🔴 Passing entire request body to entity
const user = await User.create(req.body);
// If an attacker includes { "role": "admin" }, privilege escalation occurs

// ✅ Extract only allowed fields
const { email, name, password } = dto;
const user = await User.create({ email, name, password });
```

## Dependency Security

- [ ] Are there no critical/high vulnerabilities in `npm audit` (or equivalent tool) results?
- [ ] Have unused dependencies been removed?
- [ ] Are dependency versions locked? (Lock file committed)
