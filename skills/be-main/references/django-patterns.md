# Django Best Practices (Python)

> Patterns and conventions for Django + Django REST Framework backend projects.
> See also: [architecture-guide.md](architecture-guide.md), [security-guide.md](security-guide.md)

## Project Structure

```
project/
├── manage.py
├── config/                      # Project-level settings
│   ├── __init__.py
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   ├── auth/
│   │   ├── __init__.py
│   │   ├── urls.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   ├── services.py
│   │   ├── permissions.py
│   │   └── tests/
│   │       ├── __init__.py
│   │       ├── test_views.py
│   │       └── test_services.py
│   ├── users/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── urls.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   ├── services.py
│   │   ├── managers.py
│   │   ├── admin.py
│   │   ├── migrations/
│   │   └── tests/
│   └── common/
│       ├── models.py            # Base models (timestamps, UUID mixin)
│       ├── exceptions.py
│       └── pagination.py
└── requirements/
    ├── base.txt
    ├── development.txt
    └── production.txt
```

## App-Based Architecture

Each Django app encapsulates a domain. Keep apps focused and loosely coupled.

```python
# config/urls.py
from django.urls import path, include

urlpatterns = [
    path("api/auth/", include("apps.auth.urls")),
    path("api/users/", include("apps.users.urls")),
]

# apps/users/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet

router = DefaultRouter()
router.register("", UserViewSet, basename="users")

urlpatterns = [
    path("", include(router.urls)),
]
```

## Model-View-Serializer Pattern

### Models

```python
# apps/common/models.py
import uuid
from django.db import models

class BaseModel(models.Model):
    id = models.CharField(max_length=120, primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

# apps/users/models.py
from apps.common.models import BaseModel

class User(BaseModel):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "users"
```

### Serializers

```python
# apps/users/serializers.py
from rest_framework import serializers
from .models import User

class CreateUserSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(min_length=8, write_only=True)

class UserResponseSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "created_at"]
```

- Use `Serializer` for request validation when it does not map 1:1 to a model.
- Use `ModelSerializer` for response serialization and simple CRUD.

### ViewSets

```python
# apps/users/views.py
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .serializers import CreateUserSerializer, UserResponseSerializer
from .services import UserService

class UserViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.service = UserService()

    def list(self, request):
        users = self.service.list_users()
        serializer = UserResponseSerializer(users, many=True)
        return Response(serializer.data)

    def create(self, request):
        serializer = CreateUserSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = self.service.create_user(serializer.validated_data)
        return Response(
            UserResponseSerializer(user).data,
            status=status.HTTP_201_CREATED,
        )

    def retrieve(self, request, pk=None):
        user = self.service.get_user(pk)
        return Response(UserResponseSerializer(user).data)
```

## Service Layer

Keep business logic out of views and serializers.

```python
# apps/users/services.py
from django.db import IntegrityError
from rest_framework.exceptions import NotFound, ValidationError
from .models import User

class UserService:
    def get_user(self, user_id: str) -> User:
        try:
            return User.objects.get(id=user_id, is_active=True)
        except User.DoesNotExist:
            raise NotFound("User not found.")

    def create_user(self, data: dict) -> User:
        try:
            return User.objects.create(
                email=data["email"],
                password=make_password(data["password"]),
            )
        except IntegrityError:
            raise ValidationError({"email": "Email is already registered."})

    def list_users(self):
        return User.objects.filter(is_active=True)
```

## Django ORM Queries

```python
# Efficient querying patterns
User.objects.filter(is_active=True).select_related("profile")
User.objects.filter(is_active=True).prefetch_related("orders")
User.objects.filter(created_at__gte=start_date).only("id", "email")

# Avoid N+1 queries — always use select_related / prefetch_related
# for foreign keys and many-to-many relationships.

# Bulk operations
User.objects.bulk_create([User(email=e) for e in emails])
User.objects.filter(is_active=False).update(is_active=True)
```

## Migrations

```bash
# Create migrations after model changes
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Show migration status
python manage.py showmigrations
```

- Never edit auto-generated migrations manually unless necessary (data migrations are an exception).
- Create data migrations with `python manage.py makemigrations --empty app_name`.

## Error Handling

```python
# apps/common/exceptions.py
from rest_framework.views import exception_handler

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is not None:
        response.data = {
            "error": {
                "code": exc.__class__.__name__.upper(),
                "message": str(exc.detail) if hasattr(exc, "detail") else str(exc),
            }
        }
    return response

# config/settings/base.py
REST_FRAMEWORK = {
    "EXCEPTION_HANDLER": "apps.common.exceptions.custom_exception_handler",
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 20,
}
```

## Testing with pytest-django

```python
# conftest.py
import pytest
from rest_framework.test import APIClient

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def authenticated_client(api_client, user):
    api_client.force_authenticate(user=user)
    return api_client

@pytest.fixture
def user(db):
    from apps.users.models import User
    return User.objects.create(email="test@example.com", password=make_password("pass"))

# apps/users/tests/test_views.py
@pytest.mark.django_db
class TestUserViewSet:
    def test_list_users(self, authenticated_client, user):
        response = authenticated_client.get("/api/users/")
        assert response.status_code == 200
        assert len(response.data) >= 1

    def test_create_user(self, api_client):
        response = api_client.post("/api/users/", {
            "email": "new@example.com",
            "password": "StrongP@ss1",
        })
        assert response.status_code == 201
        assert response.data["email"] == "new@example.com"

    def test_create_duplicate_email(self, api_client, user):
        response = api_client.post("/api/users/", {
            "email": "test@example.com",
            "password": "StrongP@ss1",
        })
        assert response.status_code == 400
```

- Use `@pytest.mark.django_db` for tests that access the database.
- Use `APIClient.force_authenticate()` to bypass auth in tests.
- Run with: `pytest -v`.
