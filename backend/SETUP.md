# Backend Setup Guide

## Prerequisites Installation

Since you're working with a Flutter mobile project, you likely need to install Dart. Follow these steps:

### Option 1: Using Flutter's Dart (Recommended if you have Flutter)

If you have Flutter installed for your mobile app:

1. **Locate Flutter's Dart**:
   - Flutter includes Dart SDK in its installation
   - Find it at: `<flutter-installation-path>\bin\cache\dart-sdk\bin`

2. **Add to PATH** (if not already):
   - Search for "Environment Variables" in Windows
   - Edit "Path" in System Variables
   - Add: `C:\path\to\flutter\bin\cache\dart-sdk\bin`
   - Click OK to save

3. **Verify Installation**:
   ```bash
   dart --version
   ```

### Option 2: Install Dart SDK Separately

1. **Download Dart SDK**:
   - Visit: https://dart.dev/get-dart
   - Download the Windows installer
   - Run the installer

2. **Verify Installation**:
   ```bash
   dart --version
   ```

## Installing Dependencies

Once Dart is available, run:

```bash
cd backend
dart pub get
```

Or use the provided script:
```bash
setup.bat
```

## Configuration

1. **Create .env file**:
   ```bash
   copy .env.example .env
   ```

2. **Edit .env** with your settings:
   ```
   PORT=8080
   HOST=localhost
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=sportofolio_db
   DB_USER=your_username
   DB_PASSWORD=your_password
   JWT_SECRET=your_secret_key_here
   ```

## Running the Server

### Using the batch script:
```bash
run.bat
```

### Using Dart directly:
```bash
dart run bin/server.dart
```

## Testing the Server

Once running, test with:
```bash
curl http://localhost:8080/health
```

Or open in browser: http://localhost:8080/health

## Quick Test Commands

### Test Login:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"password123\"}"
```

### Test Get Users:
```bash
curl http://localhost:8080/api/users
```

## Troubleshooting

### "dart is not recognized"
- Ensure Dart SDK is installed
- Add Dart to your PATH environment variable
- Restart your terminal/command prompt

### Port already in use
- Change PORT in .env file
- Or kill the process using port 8080

### Dependencies issues
- Delete `.dart_tool` and `pubspec.lock`
- Run `dart pub get` again

## Next Steps

1. **Set up Database**: Install PostgreSQL, MySQL, or MongoDB
2. **Configure Database Connection**: Update `.env` with database credentials
3. **Implement Database Repositories**: Add actual database logic in services
4. **Add More Routes**: Extend the API for your Sportofolio features
5. **Connect Mobile App**: Update mobile app to use this backend

## Development Tips

- Use `dart run bin/server.dart` for development
- Check logs for request details and errors
- Use tools like Postman or Thunder Client for API testing
- Modify routes in `lib/src/routes/api_routes.dart`
- Add new features in controllers and services
