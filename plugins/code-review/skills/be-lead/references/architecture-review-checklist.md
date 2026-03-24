# Backend Architecture Review Checklist

## Layered Architecture Compliance

### Layer Boundaries
- [ ] Does the Controller avoid containing business logic directly?
- [ ] Does the Controller avoid directly accessing ORM/DB?
- [ ] Is the Service unaware of HTTP concerns (Request, Response)?
- [ ] Does the Repository avoid containing business logic?
- [ ] Are DTO/Entity conversions between layers performed properly?

```
✅ Correct dependency direction:
Controller → Service → Repository → Database

❌ Incorrect dependency direction:
Controller → Repository (skipping Service)
Service → Controller (reverse dependency)
Repository → Service (reverse dependency)
```

### Dependency Injection
- [ ] Is constructor injection being used?
- [ ] Are dependencies on interfaces rather than concrete classes?
- [ ] Are there no circular dependencies?

```typescript
// ✅ Interface dependency
constructor(private userRepo: IUserRepository) {}

// ❌ Concrete class dependency (difficult to test)
constructor(private userRepo: PrismaUserRepository) {}
```

### Single Responsibility
- [ ] Does each class/module have one clear responsibility?
- [ ] Does the service avoid having too many dependencies? (Consider splitting if 5 or more)
- [ ] Are utility functions properly separated?

## API Design

### RESTful Rules
- [ ] Are HTTP methods used appropriately? (GET=read, POST=create, PUT/PATCH=update, DELETE=delete)
- [ ] Are URLs designed around resources? (`/users/:id` format)
- [ ] Are HTTP status codes appropriate? (200, 201, 204, 400, 401, 403, 404, 409, 500)
- [ ] Is the error response format consistent?

### OpenAPI Spec Compliance
- [ ] Do the endpoint's request/response match the OpenAPI spec?
- [ ] Have new endpoints been added to the OpenAPI spec?
- [ ] Does the response format follow project conventions? (direct DTO vs wrapping)

### Backward Compatibility
- [ ] Are there no renames or removals of existing fields?
- [ ] Are no new required parameters being added? (Add as optional, then gradually migrate)
- [ ] Is the behavior of existing endpoints unchanged?

## Database

### Schema Design
- [ ] Is the PK set to UUID (`VARCHAR(120)`)?
- [ ] Are necessary indexes created? (Columns used in WHERE, ORDER BY, JOIN)
- [ ] Are foreign key constraints properly set?
- [ ] Are NOT NULL constraints properly set?
- [ ] Are `created_at` and `updated_at` timestamps included?

### Migrations
- [ ] Is the migration rollback-safe?
- [ ] Has downtime impact been considered for large table changes?
- [ ] Is there a migration strategy for existing data?
- [ ] Is the migration order correct? (Create foreign-key-referenced tables first)

### Query Optimization
- [ ] Are there no N+1 queries? (Use JOIN, include, eager loading)
- [ ] Is pagination applied for full retrievals?
- [ ] Are there no unnecessary column retrievals? (Avoid SELECT *)
- [ ] Has streaming/batch processing been considered for large result sets?

```typescript
// 🔴 N+1 query
const users = await prisma.user.findMany();
for (const user of users) {
  user.orders = await prisma.order.findMany({
    where: { userId: user.id },
  });
}

// ✅ Fetch in a single query with JOIN
const users = await prisma.user.findMany({
  include: { orders: true },
});
```

## Error Handling

### Error Hierarchy
- [ ] Are custom error classes being used? (NotFoundError, ValidationError, etc.)
- [ ] Are error codes consistent?
- [ ] Does the global error handler properly handle all errors?
- [ ] Are expected and unexpected errors handled differently?

### Error Responses
- [ ] Are error messages user-friendly?
- [ ] Are internal implementation details (stack traces, DB queries, etc.) not exposed in responses?
- [ ] Is error logging performed properly? (Error level, context included)

## Test Strategy

### Test Structure
- [ ] Are there unit tests for Service logic?
- [ ] Are there integration tests for API endpoints?
- [ ] Are error cases tested, not just happy paths?
- [ ] Are there tests for boundary values (empty arrays, null, max values)?

### Test Quality
- [ ] Are mocks used appropriately? (Mock only external dependencies)
- [ ] Are tests independent of each other? (No order dependency)
- [ ] Is test data created within each test? (No shared state)
- [ ] Are assertions specific and meaningful?

## Async Processing

### Concurrency
- [ ] Are independent async operations parallelized with `Promise.all`?
- [ ] Is there protection against race conditions? (Optimistic/pessimistic locking)
- [ ] Are transactions applied where needed?

### Long-Running Tasks
- [ ] Are long-running tasks processed asynchronously via Job Queue (Bull, Agenda, etc.)?
- [ ] Is there a retry mechanism for task failures?
- [ ] Can task status be queried?

## Logging and Monitoring

- [ ] Are important business events logged?
- [ ] Are log levels appropriate? (error, warn, info, debug)
- [ ] Is a correlation ID used for request tracing?
- [ ] Is sensitive information excluded from logs?
