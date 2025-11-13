# Sportofolio Flutter App

A mobile application for sports professionals to showcase their portfolios, built with Flutter and Dart.

## Project Structure

```
lib/
├── main.dart                 # App entry point with bottom navigation
├── screens/                 # Screen widgets
│   ├── home_screen.dart     # Home feed with posts
│   ├── profile_screen.dart  # User profile screen
│   └── settings_screen.dart # Settings and preferences
├── widgets/                 # Reusable widgets
│   ├── post_widget.dart     # Post card component
│   └── search_bar.dart      # Search bar component
├── services/                # Business logic and data services
│   └── data_service.dart    # Local storage service using SharedPreferences
└── theme/                   # App theming
    └── app_theme.dart       # Colors, typography, and theme configuration
```

## Features (Phase 1)

- **Home Screen**: Feed with posts, search bar, and notifications
- **Profile Screen**: User profile with gallery and info tabs
- **Settings Screen**: Profile settings, appearance, and notifications

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Navigate to the project directory:
```bash
cd sportofolio_flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Design System

- **Background Color**: #0a0a0a (Dark theme)
- **Primary Color**: #1a1a1a
- **Accent Color**: #007AFF
- **Text Colors**: White (#FFFFFF) and Gray (#B0B0B0)

## Navigation

The app uses bottom navigation with three main sections:
- Home (Feed)
- Profile
- Settings

## Data Storage

User data is stored locally using SharedPreferences:
- Name, Bio, Email, Pronouns, URL
- User domain (coach.com or player.com)
- Settings preferences

## Responsive Design

The app is designed to be responsive across different screen sizes:
- Settings screen adapts with sidebar on larger screens
- Mobile-first approach with tab navigation
- Flexible layouts using MediaQuery

## Phase 1 Complete

All Phase 1 requirements have been implemented:
- ✅ Basic Flutter app structure with bottom navigation
- ✅ Three functional screens (Home, Profile, Settings)
- ✅ Responsive design across screen sizes
- ✅ Modern UI with consistent design system
- ✅ Local data storage using SharedPreferences
