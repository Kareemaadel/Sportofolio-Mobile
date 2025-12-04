@echo off
echo Installing Dart dependencies...
echo.

REM Check if dart is available
where dart >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Dart is not installed or not in PATH
    echo.
    echo Please install Dart SDK from: https://dart.dev/get-dart
    echo Or if you have Flutter installed, you can use: flutter pub get
    echo.
    pause
    exit /b 1
)

REM Install dependencies
dart pub get

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Dependencies installed successfully!
    echo.
    echo To run the server:
    echo dart run bin/server.dart
) else (
    echo.
    echo ✗ Failed to install dependencies
    echo Please check the error messages above
)

echo.
pause
