# Backend Security Guide

> **Note**: Examples shown for Node.js/TypeScript. Apply equivalent patterns for your framework.
> See `crew-config.json → backend.framework` for your project's framework.

## Authentication

### JWT Tokens

```typescript
// Token generation
function generateAccessToken(user: User): string {
  return jwt.sign(
    { sub: user.id, email: user.email },
    process.env.JWT_SECRET!,
    { expiresIn: '15m' }
  );
}

function generateRefreshToken(user: User): string {
  return jwt.sign(
    { sub: user.id, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET!,
    { expiresIn: '7d' }
  );
}

// Token verification middleware
function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    throw new UnauthorizedError('Token is required.');
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = payload;
    next();
  } catch (error) {
    throw new UnauthorizedError('Invalid token.');
  }
}
```

### Password Hashing

```typescript
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(
  password: string,
  hash: string
): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

## Authorization

### RBAC (Role-Based Access Control)

```typescript
// Role definition
enum Role {
  USER = 'user',
  ADMIN = 'admin',
  SUPER_ADMIN = 'super_admin',
}

// Permission decorator
function Roles(...roles: Role[]) {
  return (target: any, key: string, descriptor: PropertyDescriptor) => {
    Reflect.defineMetadata('roles', roles, target, key);
    return descriptor;
  };
}

// Permission middleware
function rolesGuard(req: Request, res: Response, next: NextFunction) {
  const requiredRoles = Reflect.getMetadata('roles', controller, methodName);

  if (!requiredRoles.includes(req.user.role)) {
    throw new ForbiddenError('You do not have permission.');
  }

  next();
}

// Usage
@Roles(Role.ADMIN)
async deleteUser(userId: string) { ... }
```

### Resource-Based Permissions

```typescript
// Access own resources only
async function checkOwnership(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const resource = await resourceRepo.findById(req.params.id);

  if (resource.userId !== req.user.id) {
    throw new ForbiddenError('You can only access your own resources.');
  }

  next();
}
```

## Input Validation

### XSS Prevention

```typescript
import DOMPurify from 'isomorphic-dompurify';

function sanitizeHtml(input: string): string {
  return DOMPurify.sanitize(input);
}

// Escape on output
function escapeHtml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
```

### SQL Injection Prevention

```typescript
// Good - Parameterized Query
const user = await prisma.user.findFirst({
  where: { email: userInput },
});

// Good - Prepared Statement
const result = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [userInput]
);

// Bad - String concatenation
const result = await db.query(
  `SELECT * FROM users WHERE email = '${userInput}'`  // Dangerous!
);
```

### Path Traversal Prevention

```typescript
import path from 'path';

function safeFilePath(userInput: string): string {
  const baseDir = '/app/uploads';
  const resolved = path.resolve(baseDir, userInput);

  // Check if the path escapes beyond baseDir
  if (!resolved.startsWith(baseDir)) {
    throw new Error('Invalid file path');
  }

  return resolved;
}
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// Global limit
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per IP
  message: { error: 'Too many requests' },
});

// Authentication endpoint limit (stricter)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 login attempts
  message: { error: 'Too many login attempts' },
});

app.use('/api/', globalLimiter);
app.use('/api/auth/login', authLimiter);
```

## CORS Configuration

```typescript
import cors from 'cors';

const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = [
      'https://app.example.com',
      'https://admin.example.com',
    ];

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('CORS not allowed'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

app.use(cors(corsOptions));
```

## Security Headers

```typescript
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
  },
}));
```

## Sensitive Data Handling

### Exclude from Responses

```typescript
class UserResponse {
  id: string;
  email: string;
  // password excluded

  static from(user: User): UserResponse {
    return {
      id: user.id,
      email: user.email,
    };
  }
}
```

### Mask in Logs

```typescript
function maskSensitiveData(data: any): any {
  const sensitiveFields = ['password', 'token', 'creditCard'];

  return Object.entries(data).reduce((acc, [key, value]) => {
    if (sensitiveFields.includes(key)) {
      acc[key] = '***MASKED***';
    } else {
      acc[key] = value;
    }
    return acc;
  }, {} as any);
}

logger.info('Request:', maskSensitiveData(req.body));
```

## Environment Variable Management

```typescript
// .env.example (committed)
DATABASE_URL=
JWT_SECRET=
AWS_ACCESS_KEY=

// Environment variable validation
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  NODE_ENV: z.enum(['development', 'production', 'test']),
});

const env = envSchema.parse(process.env);
```

## Security Checklist

- [ ] Authentication/authorization applied to all endpoints
- [ ] Input validation
- [ ] SQL Injection prevention (ORM/Prepared Statement)
- [ ] XSS prevention (sanitize input, escape output)
- [ ] CSRF prevention (token or SameSite cookies)
- [ ] Rate Limiting applied
- [ ] CORS configured
- [ ] Security headers configured (Helmet)
- [ ] HTTPS enforced
- [ ] Sensitive data masked/excluded
- [ ] Internal information not exposed in error messages
- [ ] Dependency security vulnerability scanning (npm audit)
