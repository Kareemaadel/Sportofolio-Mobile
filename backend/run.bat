@echo off
echo Starting Sportofolio Backend Server...
echo.

REM Check if .env file exists
if not exist .env (
    echo WARNING: .env file not found
    echo Creating .env file from .env.example...
    copy .env.example .env
    echo.
    echo Please update .env file with your configuration before running the server!
    echo.
    pause
    exit /b 1
)

REM Check if dart is available
where dart >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Dart is not installed or not in PATH
    echo.
    echo Please install Dart SDK from: https://dart.dev/get-dart
    echo Or if you have Flutter installed, you can use: flutter run -d dart
    echo.
    pause
    exit /b 1
)

echo Server starting on http://localhost:8080
echo Press Ctrl+C to stop the server
echo.

dart run bin/server.dart
