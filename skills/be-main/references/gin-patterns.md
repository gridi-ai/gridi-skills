# Gin Best Practices (Go)

> Patterns and conventions for Gin backend projects.
> See also: [architecture-guide.md](architecture-guide.md), [security-guide.md](security-guide.md)

## Project Structure

```
.
├── cmd/
│   └── server/
│       └── main.go              # Entrypoint
├── internal/
│   ├── config/
│   │   └── config.go            # Env-based configuration
│   ├── router/
│   │   └── router.go            # Route registration
│   ├── middleware/
│   │   ├── auth.go
│   │   ├── cors.go
│   │   └── logger.go
│   ├── handler/
│   │   ├── auth_handler.go
│   │   └── user_handler.go
│   ├── service/
│   │   ├── auth_service.go
│   │   └── user_service.go
│   ├── repository/
│   │   └── user_repository.go
│   ├── model/
│   │   └── user.go              # GORM model
│   ├── dto/
│   │   ├── auth_request.go
│   │   └── user_response.go
│   └── apperror/
│       └── errors.go
├── migrations/
├── go.mod
└── go.sum
```

- Use `internal/` to prevent external imports.
- Use `cmd/` for the application entrypoint.
- Keep packages small and focused.

## Handler / Service / Repository Pattern

### Handler

```go
// internal/handler/user_handler.go
type UserHandler struct {
    service service.UserService
}

func NewUserHandler(svc service.UserService) *UserHandler {
    return &UserHandler{service: svc}
}

func (h *UserHandler) List(c *gin.Context) {
    users, err := h.service.ListUsers(c.Request.Context())
    if err != nil {
        handleError(c, err)
        return
    }
    c.JSON(http.StatusOK, users)
}

func (h *UserHandler) Create(c *gin.Context) {
    var req dto.CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": gin.H{"code": "VALIDATION_ERROR", "message": err.Error()},
        })
        return
    }

    user, err := h.service.CreateUser(c.Request.Context(), req)
    if err != nil {
        handleError(c, err)
        return
    }
    c.JSON(http.StatusCreated, user)
}
```

### Service

```go
// internal/service/user_service.go
type UserService interface {
    ListUsers(ctx context.Context) ([]dto.UserResponse, error)
    CreateUser(ctx context.Context, req dto.CreateUserRequest) (*dto.UserResponse, error)
    GetUser(ctx context.Context, id string) (*dto.UserResponse, error)
}

type userService struct {
    repo repository.UserRepository
}

func NewUserService(repo repository.UserRepository) UserService {
    return &userService{repo: repo}
}

func (s *userService) CreateUser(ctx context.Context, req dto.CreateUserRequest) (*dto.UserResponse, error) {
    existing, _ := s.repo.FindByEmail(ctx, req.Email)
    if existing != nil {
        return nil, apperror.NewConflict("Email is already registered.")
    }

    hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        return nil, fmt.Errorf("hash password: %w", err)
    }

    user := &model.User{
        ID:       uuid.New().String(),
        Email:    req.Email,
        Password: string(hashed),
    }
    if err := s.repo.Create(ctx, user); err != nil {
        return nil, err
    }

    return dto.NewUserResponse(user), nil
}
```

### Repository

```go
// internal/repository/user_repository.go
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*model.User, error)
    FindByEmail(ctx context.Context, email string) (*model.User, error)
    Create(ctx context.Context, user *model.User) error
}

type userRepository struct {
    db *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
    return &userRepository{db: db}
}

func (r *userRepository) FindByEmail(ctx context.Context, email string) (*model.User, error) {
    var user model.User
    result := r.db.WithContext(ctx).Where("email = ?", email).First(&user)
    if errors.Is(result.Error, gorm.ErrRecordNotFound) {
        return nil, nil
    }
    return &user, result.Error
}

func (r *userRepository) Create(ctx context.Context, user *model.User) error {
    return r.db.WithContext(ctx).Create(user).Error
}
```

- Define interfaces for service and repository layers.
- Accept interfaces, return structs.
- Use constructor functions (`NewXxx`) for dependency wiring.

## Middleware

```go
// internal/middleware/auth.go
func AuthMiddleware(jwtSecret string) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": gin.H{"code": "UNAUTHORIZED", "message": "Missing token"},
            })
            return
        }
        claims, err := parseJWT(token, jwtSecret)
        if err != nil {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": gin.H{"code": "UNAUTHORIZED", "message": "Invalid token"},
            })
            return
        }
        c.Set("userID", claims.UserID)
        c.Next()
    }
}

// internal/router/router.go
func Setup(r *gin.Engine, h *handler.UserHandler, cfg *config.Config) {
    r.Use(middleware.Logger(), middleware.CORS())

    api := r.Group("/api")
    {
        auth := api.Group("/auth")
        auth.POST("/signup", h.Signup)
        auth.POST("/login", h.Login)

        users := api.Group("/users")
        users.Use(middleware.AuthMiddleware(cfg.JWTSecret))
        users.GET("", h.List)
        users.GET("/:id", h.Get)
    }
}
```

## Validation with go-playground/validator

```go
// internal/dto/auth_request.go
type CreateUserRequest struct {
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required,min=8"`
}

type LoginRequest struct {
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required"`
}
```

- Gin uses `go-playground/validator` via `binding` tags.
- `c.ShouldBindJSON(&req)` validates automatically.
- Add custom validators if needed:

```go
if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
    v.RegisterValidation("strong_password", strongPasswordValidator)
}
```

## GORM Integration

```go
// internal/model/user.go
type User struct {
    ID        string    `gorm:"primaryKey;size:120"`
    Email     string    `gorm:"uniqueIndex;not null"`
    Password  string    `gorm:"not null"`
    CreatedAt time.Time
    UpdatedAt time.Time
}

// Database setup
func NewDB(cfg *config.Config) (*gorm.DB, error) {
    db, err := gorm.Open(postgres.Open(cfg.DatabaseURL), &gorm.Config{})
    if err != nil {
        return nil, fmt.Errorf("connect to database: %w", err)
    }
    return db, nil
}
```

- Use `AutoMigrate` only in development; use a migration tool (golang-migrate) in production.

## Error Handling

```go
// internal/apperror/errors.go
type AppError struct {
    StatusCode int    `json:"-"`
    Code       string `json:"code"`
    Message    string `json:"message"`
}

func (e *AppError) Error() string { return e.Message }

func NewNotFound(msg string) *AppError {
    return &AppError{StatusCode: http.StatusNotFound, Code: "NOT_FOUND", Message: msg}
}

func NewConflict(msg string) *AppError {
    return &AppError{StatusCode: http.StatusConflict, Code: "CONFLICT", Message: msg}
}

// Handler helper
func handleError(c *gin.Context, err error) {
    var appErr *AppError
    if errors.As(err, &appErr) {
        c.JSON(appErr.StatusCode, gin.H{"error": appErr})
        return
    }
    log.Printf("unhandled error: %v", err)
    c.JSON(http.StatusInternalServerError, gin.H{
        "error": gin.H{"code": "INTERNAL_ERROR", "message": "A server error occurred."},
    })
}
```

## Testing with net/http/httptest

```go
// internal/handler/user_handler_test.go
func setupTestRouter(svc service.UserService) *gin.Engine {
    gin.SetMode(gin.TestMode)
    r := gin.New()
    h := handler.NewUserHandler(svc)
    r.POST("/api/users", h.Create)
    r.GET("/api/users", h.List)
    return r
}

func TestCreateUser_Success(t *testing.T) {
    mockSvc := &mockUserService{
        createFn: func(ctx context.Context, req dto.CreateUserRequest) (*dto.UserResponse, error) {
            return &dto.UserResponse{ID: "123", Email: req.Email}, nil
        },
    }

    router := setupTestRouter(mockSvc)
    body := `{"email":"test@example.com","password":"StrongP@ss1"}`
    req := httptest.NewRequest(http.MethodPost, "/api/users", strings.NewReader(body))
    req.Header.Set("Content-Type", "application/json")
    w := httptest.NewRecorder()

    router.ServeHTTP(w, req)

    assert.Equal(t, http.StatusCreated, w.Code)
    var resp dto.UserResponse
    json.Unmarshal(w.Body.Bytes(), &resp)
    assert.Equal(t, "test@example.com", resp.Email)
}

func TestCreateUser_InvalidEmail(t *testing.T) {
    router := setupTestRouter(&mockUserService{})
    body := `{"email":"invalid","password":"StrongP@ss1"}`
    req := httptest.NewRequest(http.MethodPost, "/api/users", strings.NewReader(body))
    req.Header.Set("Content-Type", "application/json")
    w := httptest.NewRecorder()

    router.ServeHTTP(w, req)

    assert.Equal(t, http.StatusBadRequest, w.Code)
}
```

- Use `httptest.NewRecorder()` and `gin.TestMode` for handler tests.
- Define mock interfaces for service and repository layers.
- Use `testify/assert` for assertions.
- Run with: `go test ./...`.
