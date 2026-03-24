# FastAPI Best Practices (Python)

> Patterns and conventions for FastAPI backend projects.
> See also: [architecture-guide.md](architecture-guide.md), [security-guide.md](security-guide.md)

## Project Structure

```
app/
├── main.py                      # FastAPI app & lifespan
├── config.py                    # Settings with pydantic-settings
├── database.py                  # SQLAlchemy engine & session
├── dependencies.py              # Shared Depends() providers
├── routers/
│   ├── __init__.py
│   ├── auth.py
│   └── users.py
├── services/
│   ├── __init__.py
│   ├── auth_service.py
│   └── user_service.py
├── repositories/
│   ├── __init__.py
│   └── user_repository.py
├── models/
│   └── user.py                  # SQLAlchemy models
├── schemas/
│   ├── __init__.py
│   ├── auth.py                  # Pydantic request/response
│   └── user.py
├── middlewares/
│   └── error_handler.py
├── exceptions/
│   ├── __init__.py
│   └── app_exceptions.py
└── tests/
    ├── conftest.py
    ├── test_auth.py
    └── test_users.py
alembic/
├── env.py
└── versions/
alembic.ini
```

## Router-Based Architecture

```python
# routers/auth.py
from fastapi import APIRouter, Depends
from app.schemas.auth import SignupRequest, TokenResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/signup", status_code=201)
async def signup(
    body: SignupRequest,
    auth_service: AuthService = Depends(),
):
    return await auth_service.signup(body)

# main.py
from fastapi import FastAPI
from app.routers import auth, users

app = FastAPI()
app.include_router(auth.router)
app.include_router(users.router)
```

## Dependency Injection with Depends()

```python
# database.py
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

engine = create_async_engine(settings.DATABASE_URL)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session

# repositories/user_repository.py
class UserRepository:
    def __init__(self, db: AsyncSession = Depends(get_db)):
        self.db = db

    async def find_by_email(self, email: str) -> User | None:
        result = await self.db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

# services/user_service.py
class UserService:
    def __init__(self, repo: UserRepository = Depends()):
        self.repo = repo
```

- Chain `Depends()` for layered injection: router -> service -> repository -> session.
- Use `Depends(get_current_user)` for auth-protected routes.

## Pydantic Models for Validation

```python
# schemas/auth.py
from pydantic import BaseModel, EmailStr, Field

class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)

class UserResponse(BaseModel):
    id: str
    email: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
```

- Use `model_config = ConfigDict(from_attributes=True)` to convert ORM objects.
- Define separate request and response schemas.

## SQLAlchemy Async Models

```python
# models/user.py
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import String, DateTime
from datetime import datetime

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(120), primary_key=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
```

## Alembic Migrations

```bash
# Initialize
alembic init alembic

# Generate migration
alembic revision --autogenerate -m "create users table"

# Apply
alembic upgrade head

# Rollback
alembic downgrade -1
```

Configure `alembic/env.py` to import your `Base.metadata` and use the async engine.

## Error Handling

```python
# exceptions/app_exceptions.py
from fastapi import HTTPException

class AppException(HTTPException):
    def __init__(self, status_code: int, code: str, message: str):
        super().__init__(status_code=status_code, detail={"code": code, "message": message})

class NotFoundError(AppException):
    def __init__(self, message: str = "Resource not found"):
        super().__init__(404, "NOT_FOUND", message)

class ConflictError(AppException):
    def __init__(self, message: str = "Resource already exists"):
        super().__init__(409, "CONFLICT", message)

# Custom exception handler (optional, for non-HTTPException errors)
@app.exception_handler(Exception)
async def unhandled_exception_handler(request, exc):
    return JSONResponse(
        status_code=500,
        content={"error": {"code": "INTERNAL_ERROR", "message": "A server error occurred."}},
    )
```

## Middleware

```python
# main.py
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Custom middleware
@app.middleware("http")
async def request_logging(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    logger.info(f"{request.method} {request.url.path} {response.status_code} {duration:.3f}s")
    return response
```

## Testing with pytest + httpx

```python
# tests/conftest.py
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.database import get_db

@pytest.fixture
async def client(test_db_session):
    app.dependency_overrides[get_db] = lambda: test_db_session
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac
    app.dependency_overrides.clear()

# tests/test_auth.py
@pytest.mark.asyncio
async def test_signup(client: AsyncClient):
    response = await client.post("/auth/signup", json={
        "email": "test@example.com",
        "password": "StrongP@ss1",
    })
    assert response.status_code == 201
    assert "id" in response.json()

@pytest.mark.asyncio
async def test_signup_duplicate_email(client: AsyncClient):
    await client.post("/auth/signup", json={...})
    response = await client.post("/auth/signup", json={...})
    assert response.status_code == 409
```

- Use `dependency_overrides` to swap real DB sessions with test sessions.
- Use `pytest-asyncio` for async test support.
- Run with: `pytest -v --asyncio-mode=auto`.
