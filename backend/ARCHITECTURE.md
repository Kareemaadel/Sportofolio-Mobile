# Backend Architecture

## Project Structure
```
backend/
├── bin/
│   └── server.dart               # Main entry point
├── lib/
│   └── src/
│       ├── config/              # Configuration
│       │   └── database.dart
│       ├── controllers/         # HTTP Request Handlers
│       │   ├── auth_controller.dart
│       │   └── user_controller.dart
│       ├── middleware/          # Request/Response Processing
│       │   ├── error_middleware.dart
│       │   └── logger_middleware.dart
│       ├── models/              # Data Models
│       │   └── user.dart
│       ├── routes/              # Route Definitions
│       │   └── api_routes.dart
│       └── services/            # Business Logic
│           └── auth_service.dart
├── test/
│   └── api_test.dart            # Unit Tests
├── .env.example                 # Environment Template
├── .gitignore
├── analysis_options.yaml        # Linting Rules
├── pubspec.yaml                 # Dependencies
├── README.md                    # Documentation
├── SETUP.md                     # Setup Instructions
├── run.bat                      # Run Script
└── setup.bat                    # Setup Script
```

## Request Flow

```
Client Request
    ↓
[Server Entry (bin/server.dart)]
    ↓
[Middleware Pipeline]
    ├── CORS Headers
    ├── Logger Middleware (logs request)
    └── Error Middleware (catches errors)
    ↓
[Router (api_routes.dart)]
    ↓
[Controller (auth/user_controller.dart)]
    ↓
[Service Layer (auth_service.dart)]
    ↓
[Database/Models]
    ↓
[Response]
    ↓
Client
```

## Technology Stack

### Core Framework
- **Shelf**: HTTP server framework
- **Shelf Router**: Routing system
- **Shelf CORS**: Cross-Origin Resource Sharing

### Authentication & Security
- **JWT**: Token-based authentication
- **BCrypt**: Password hashing
- **Crypto**: Additional security utilities

### Database Support
- **PostgreSQL**: via `postgres` package
- **MySQL**: via `mysql1` package
- **MongoDB**: via `mongo_dart` package

### Utilities
- **DotEnv**: Environment configuration
- **Logging**: Request/error logging
- **Validators**: Input validation
- **UUID**: Unique identifier generation
- **MIME**: File type detection

### Development Tools
- **Test**: Unit testing framework
- **Mockito**: Mocking for tests
- **Lints**: Code quality
- **Build Runner**: Code generation
- **JSON Serializable**: JSON handling

## API Architecture

### RESTful Endpoints

#### Authentication (`/api/auth/`)
- `POST /login` - Authenticate user
- `POST /register` - Create new account
- `POST /refresh` - Refresh access token

#### Users (`/api/users/`)
- `GET /` - List all users
- `GET /:id` - Get user by ID
- `POST /` - Create user
- `PUT /:id` - Update user
- `DELETE /:id` - Delete user

### Authentication Flow

```
1. User Registration
   POST /api/auth/register
   → Hash password with BCrypt
   → Store in database
   → Generate JWT token
   → Return token + user data

2. User Login
   POST /api/auth/login
   → Verify credentials
   → Generate JWT access token (24h)
   → Generate refresh token (30d)
   → Return tokens + user data

3. Token Refresh
   POST /api/auth/refresh
   → Verify refresh token
   → Generate new access token
   → Return new tokens

4. Protected Routes
   → Extract JWT from Authorization header
   → Verify token signature
   → Extract user ID from payload
   → Process request
```

## Security Features

1. **Password Hashing**: BCrypt with salt
2. **JWT Tokens**: Signed with secret key
3. **Token Expiration**: Access (24h), Refresh (30d)
4. **CORS Protection**: Configurable origins
5. **Error Sanitization**: No sensitive data in errors
6. **Environment Variables**: Secrets not in code

## Database Configuration

Update `.env` file:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sportofolio_db
DB_USER=your_user
DB_PASSWORD=your_password
```

## Middleware Pipeline

1. **CORS Middleware**
   - Adds CORS headers
   - Allows cross-origin requests

2. **Logger Middleware**
   - Logs request method, URL
   - Tracks response time
   - Records status codes

3. **Error Middleware**
   - Catches exceptions
   - Formats error responses
   - Prevents server crashes

## Extending the Backend

### Adding a New Feature

1. **Create Model** (`lib/src/models/feature.dart`)
   ```dart
   class Feature {
     final String id;
     final String name;
     // ...
   }
   ```

2. **Create Service** (`lib/src/services/feature_service.dart`)
   ```dart
   class FeatureService {
     static Future<List<Feature>> getAll() async {
       // Business logic
     }
   }
   ```

3. **Create Controller** (`lib/src/controllers/feature_controller.dart`)
   ```dart
   class FeatureController {
     static Future<Response> getAll(Request request) async {
       // Handle HTTP request
     }
   }
   ```

4. **Add Routes** (`lib/src/routes/api_routes.dart`)
   ```dart
   router.get('/features', FeatureController.getAll);
   ```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port | 8080 |
| HOST | Server host | localhost |
| DB_HOST | Database host | localhost |
| DB_PORT | Database port | 5432 |
| DB_NAME | Database name | sportofolio_db |
| DB_USER | Database user | postgres |
| DB_PASSWORD | Database password | - |
| JWT_SECRET | JWT signing key | - |
| JWT_EXPIRATION | Token expiration (seconds) | 86400 |
| ALLOWED_ORIGINS | CORS origins | localhost |

## Best Practices

1. **Separation of Concerns**
   - Controllers handle HTTP
   - Services contain business logic
   - Models define data structure

2. **Error Handling**
   - Use try-catch in controllers
   - Return appropriate HTTP status codes
   - Log errors for debugging

3. **Security**
   - Never commit `.env` file
   - Use environment variables for secrets
   - Validate all user input

4. **Testing**
   - Write tests for all endpoints
   - Mock external dependencies
   - Test error cases

5. **Code Quality**
   - Follow Dart style guidelines
   - Use linting rules
   - Document complex logic
