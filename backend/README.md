# Sportofolio Backend

RESTful API server for the Sportofolio mobile application built with Dart and Shelf framework.

## Features

- 🚀 RESTful API with Shelf framework
- 🔐 JWT Authentication
- 🗄️ Database support (PostgreSQL, MySQL, MongoDB)
- 🔒 Password hashing with bcrypt
- 📝 Request logging
- ⚠️ Error handling middleware
- 🌐 CORS support
- 📦 Environment-based configuration

## Prerequisites

- Dart SDK 3.0.0 or higher
- Database (PostgreSQL/MySQL/MongoDB)

## Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
dart pub get
```

3. Create a `.env` file from the example:
```bash
cp .env.example .env
```

4. Update the `.env` file with your configuration:
```env
PORT=8080
HOST=localhost
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sportofolio_db
DB_USER=your_user
DB_PASSWORD=your_password
JWT_SECRET=your_secret_key
```

## Running the Server

### Development Mode
```bash
dart run bin/server.dart
```

### Production Mode
```bash
dart compile exe bin/server.dart -o server
./server
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Refresh access token

### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Health Check
- `GET /health` - Server health status

## Project Structure

```
backend/
├── bin/
│   └── server.dart           # Main entry point
├── lib/
│   └── src/
│       ├── config/          # Configuration files
│       │   └── database.dart
│       ├── controllers/     # Request handlers
│       │   ├── auth_controller.dart
│       │   └── user_controller.dart
│       ├── middleware/      # Middleware
│       │   ├── error_middleware.dart
│       │   └── logger_middleware.dart
│       ├── models/          # Data models
│       │   └── user.dart
│       ├── routes/          # Route definitions
│       │   └── api_routes.dart
│       └── services/        # Business logic
│           └── auth_service.dart
├── .env.example             # Environment variables template
├── .gitignore
├── pubspec.yaml             # Dependencies
└── README.md
```

## Development

### Adding New Routes

1. Create a controller in `lib/src/controllers/`
2. Add routes in `lib/src/routes/api_routes.dart`
3. Implement business logic in `lib/src/services/`

### Environment Variables

All configuration is managed through environment variables. See `.env.example` for available options.

## Testing

```bash
dart test
```

## Dependencies

- **shelf**: Web server framework
- **shelf_router**: Routing
- **shelf_cors_headers**: CORS support
- **dart_jsonwebtoken**: JWT authentication
- **bcrypt**: Password hashing
- **postgres/mysql1/mongo_dart**: Database drivers
- **dotenv**: Environment configuration
- **logging**: Logging utilities

## License

MIT License
