# API Examples

Test these endpoints using curl, Postman, or any HTTP client.

## Base URL
```
http://localhost:8080
```

---

## Health Check

### Check Server Status
```bash
curl http://localhost:8080/health
```

**Response:**
```
Server is running
```

---

## Authentication Endpoints

### 1. Register New User

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"John Doe\",
    \"email\": \"john@example.com\",
    \"password\": \"password123\"
  }"
```

**Success Response (201):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "2",
    "email": "john@example.com",
    "name": "John Doe"
  }
}
```

---

### 2. Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"john@example.com\",
    \"password\": \"password123\"
  }"
```

**Success Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "1",
    "email": "john@example.com",
    "name": "John Doe"
  }
}
```

**Error Response (401):**
```json
{
  "error": "Invalid credentials"
}
```

---

### 3. Refresh Token

```bash
curl -X POST http://localhost:8080/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d "{
    \"refreshToken\": \"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...\"
  }"
```

**Success Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## User Endpoints

### 1. Get All Users

```bash
curl http://localhost:8080/api/users
```

**Success Response (200):**
```json
{
  "users": [
    {
      "id": "1",
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "id": "2",
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  ]
}
```

---

### 2. Get User by ID

```bash
curl http://localhost:8080/api/users/1
```

**Success Response (200):**
```json
{
  "id": "1",
  "name": "John Doe",
  "email": "john@example.com"
}
```

---

### 3. Create User

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Alice Johnson\",
    \"email\": \"alice@example.com\"
  }"
```

**Success Response (201):**
```json
{
  "id": "3",
  "name": "Alice Johnson",
  "email": "alice@example.com"
}
```

---

### 4. Update User

```bash
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"John Updated\",
    \"email\": \"john.updated@example.com\"
  }"
```

**Success Response (200):**
```json
{
  "id": "1",
  "name": "John Updated",
  "email": "john.updated@example.com"
}
```

---

### 5. Delete User

```bash
curl -X DELETE http://localhost:8080/api/users/1
```

**Success Response (200):**
```json
{
  "message": "User deleted successfully",
  "id": "1"
}
```

---

## Using with Authorization (After Login)

Once you have a JWT token from login/register, you can use it in protected routes:

```bash
curl http://localhost:8080/api/users \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## PowerShell Examples

If using PowerShell on Windows:

### Login
```powershell
$body = @{
    email = "john@example.com"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $body -ContentType "application/json"
```

### Get Users
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/users" -Method GET
```

### Create User
```powershell
$body = @{
    name = "Alice Johnson"
    email = "alice@example.com"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/users" -Method POST -Body $body -ContentType "application/json"
```

---

## Postman Collection

You can create a Postman collection with these requests:

1. **Create Environment Variables:**
   - `base_url`: `http://localhost:8080`
   - `token`: (set after login)

2. **Import these as requests:**
   - Each endpoint listed above
   - Set Authorization header as `Bearer {{token}}` for protected routes

---

## Testing Tools

### Recommended Tools:
1. **Postman** - Full-featured API testing
2. **Thunder Client** (VS Code extension) - Lightweight alternative
3. **curl** - Command line testing
4. **HTTPie** - User-friendly curl alternative

### Install HTTPie (Optional):
```bash
pip install httpie
```

### Use HTTPie:
```bash
# Login
http POST http://localhost:8080/api/auth/login email=john@example.com password=password123

# Get users
http GET http://localhost:8080/api/users
```

---

## Common HTTP Status Codes

| Code | Meaning | When to Expect |
|------|---------|----------------|
| 200 | OK | Successful GET, PUT, DELETE |
| 201 | Created | Successful POST (creation) |
| 400 | Bad Request | Invalid/missing data |
| 401 | Unauthorized | Invalid credentials/token |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Server-side issue |

---

## Error Response Format

All errors follow this format:

```json
{
  "error": "Description of the error"
}
```

Or with additional data:

```json
{
  "error": "Validation failed",
  "data": {
    "field": "email",
    "message": "Invalid email format"
  }
}
```

---

## Next Steps

1. Set up your database
2. Implement actual database operations in services
3. Add authentication middleware to protect routes
4. Extend with more endpoints specific to Sportofolio
5. Connect your Flutter mobile app to this backend
