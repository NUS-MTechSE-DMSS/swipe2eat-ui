# Swipe2Eat UI

A Flutter application for discovering and saving food items through an intuitive swipe-based interface, with full backend integration for preferences, user authentication, and food discovery APIs.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [API Integration](#api-integration)
- [Dependencies](#dependencies)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

## Features

### 🍽️ Core Features
- **Swipe-based Food Discovery**: Tinder-style interface for browsing restaurants and dishes
- **User Preferences**: Customize cuisine preferences, budget, spice level, and dietary restrictions
- **Favorites Management**: Save and manage favorite dishes
- **User Profile**: View and edit personal preferences
- **Responsive Design**: Works seamlessly on iOS, Android, and Web

### 🔄 Backend Integration
- **Food Discovery API**: Fetches restaurants based on user preferences (cuisines, budget, spice level, dietary restrictions, allergens)
- **Preference Persistence**: Saves user preferences locally and syncs with backend
- **Swipe Tracking**: Records user interactions (likes/dislikes) for personalized recommendations
- **Favorites Sync**: Loads and displays user's liked items from backend
- **AWS Cognito Ready**: Built-in infrastructure for user authentication (Cognito integration pending)

### 💾 Local Storage
- **SharedPreferences Integration**: Persists user preferences across app sessions
  - Cuisines selection
  - Budget level (low/medium/high)
  - Spice preference (Mild/Medium/Hot)
  - Dietary type and allergens
  - Temporary user ID

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

### Required

- **Flutter SDK** (version ^3.10.7)
  - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
  - Verify installation: `flutter --version`

- **Dart SDK** (included with Flutter)
  - Verify installation: `dart --version`

- **Git**
  - Download from [git-scm.com](https://git-scm.com/)
  - Verify installation: `git --version`

### Platform-Specific Requirements

#### For iOS Development (macOS)
- **Xcode** (14.0 or later)
  - Install from App Store or: `xcode-select --install`
- **CocoaPods**
  - Install via: `sudo gem install cocoapods`
- **iOS Deployment Target**: 11.0 or higher

#### For Android Development
- **Android Studio** or **Android SDK**
  - Download from [developer.android.com](https://developer.android.com/studio)
  - Minimum SDK version: 21
  - Target SDK version: Latest available

#### For Web Development
- No additional prerequisites beyond Flutter SDK

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/NUS-MTechSE-DMSS/swipe2eat-ui.git
cd swipe2eat_ui
```

### 2. Verify Flutter Setup

```bash
flutter doctor
```

This command checks your environment and reports any missing dependencies. Address any issues reported before proceeding.

### 3. Get Project Dependencies

```bash
flutter pub get
```

This fetches all required packages specified in `pubspec.yaml`:
- **http**: HTTP client for API calls
- **shared_preferences**: Local storage for user preferences
- **provider**: State management (v6.1.2)
- **google_fonts**: Custom fonts support (v6.2.1)
- **cupertino_icons**: iOS-style icons (v1.0.8)

### 4. (iOS Only) Install iOS Pods

```bash
cd ios
pod install
cd ..
```

## Configuration

### Backend API Endpoint

The app reads the backend API base URL from `ApiConfig.baseUrl`, which is compiled from `API_BASE_URL` at build time. Update `config/env/*.json` instead of editing individual service files.

**Current Shared AWS Backend Base URL:**
```
https://dev.keiyam.me
```

### User ID Configuration

The app uses a temporary user ID stored in SharedPreferences. This will be replaced with actual AWS Cognito user IDs once authentication is implemented.

**Storage Key:** `prefs.tempUserId`
**Default Fallback:** `22222222-2222-2222-2222-222222222222`

## Running the App

### On iOS Simulator

```bash
flutter run -d <simulator_id>
```

To list available simulators:
```bash
flutter emulators
```

Or open Xcode and select a simulator before running:
```bash
flutter run
```

### On Android Emulator

```bash
flutter run -d <emulator_id>
```

To list available emulators:
```bash
flutter emulators
```

Or create a new Android Virtual Device (AVD) using Android Studio.

### On Physical Device

#### iOS Device
1. Connect your iPhone via USB
2. Trust the computer on the device
3. Run: `flutter run -d <device_id>`

#### Android Device
1. Enable Developer Mode (tap Build Number 7 times in Settings > About)
2. Enable USB Debugging in Developer Options
3. Connect via USB
4. Run: `flutter run -d <device_id>`

To list connected devices:
```bash
flutter devices
```

### On Web

```bash
flutter run -d chrome
```

Other supported platforms: `firefox`, `edge`

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # App configuration and routes
├── core/                               # Core utilities and services
│   ├── navigation/
│   │   └── main_shell.dart            # Bottom navigation shell
│   ├── services/
│   │   └── preferences_service.dart   # API & local storage for preferences
│   ├── state/
│   │   └── favorites_store.dart       # In-memory favorites state management
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── widgets/
│       └── gradient_button.dart       # Reusable gradient button
└── features/
    ├── auth/                           # Authentication screens
    │   └── screens/
    │       ├── sign_in_screen.dart    # Sign in with validations
    │       └── sign_up_screen.dart    # Sign up with validations
    ├── discover/                       # Food discovery feature
    │   └── discover_screen.dart       # Swipeable food cards with API integration
    ├── favorites/                      # Favorites management
    │   ├── favorites_screen.dart      # Display liked foods from API
    │   └── food_detail_screen.dart    # Food item details
    ├── onboarding/                     # Onboarding flow
    │   └── screens/
    │       ├── welcome_screen.dart
    │       ├── cuisine_screen.dart    # Select cuisines (hardcoded list)
    │       ├── budget_screen.dart     # Select budget (map to API values)
    │       ├── spice_screen.dart      # Select spice level
    │       ├── dietary_screen.dart    # Select diet type & allergens with API fallback
    │       └── done_screen.dart
    └── profile/                        # User profile
        └── profile_screen.dart        # Show preferences + edit dialog
└── models/
    └── food_item.dart                 # Food data model with flexible parsing
```

## API Integration

### Overview

The app integrates with a backend API for food discovery, preference management, and user interactions.

### Endpoints

#### Food Discovery
```
GET /food?cuisines=Thai&cuisines=Chinese&budget=low&spice=Medium&dietType=Vegetarian&allergens=Peanut
```
Returns paginated list of restaurants and dishes matching user preferences.

#### Dietary Options
```
GET /dietary/options
```
Returns available diet types and allergens. **2-second timeout with local fallback values.**

#### Swipe Preferences (Tracking)
```
POST /preference/food/swipe
Body: { "userId": "...", "foodId": "...", "status": true }
```
Records user interaction with food items (like/dislike).

#### Get User Favorites
```
GET /preference/food/users/{userId}
```
Retrieves list of foods liked by the user.

#### Update User Preferences
```
PUT /preference/users/{userId}
Body: { "cuisines": [...], "budget": "low" }
```
Updates user's cuisine and budget preferences.

### Response Parsing

The app handles flexible API responses:
- **Cuisine field**: Supports both string and array formats
- **Budget values**: Maps user-friendly labels to API values (low/medium/high)
- **Error handling**: Graceful fallbacks with local cached data where possible
- **Timeouts**: 2-second timeout on dietary API with hardcoded fallback options

### Authentication (In Progress)

TODO: AWS Cognito integration for:
- User sign in/sign up
- ID token management
- Bearer token in Authorization headers

## Dependencies

### Core Dependencies
- **flutter**: Flutter SDK for UI development
- **http**: ^1.1.0 - HTTP client for API calls
- **shared_preferences**: ^2.2.3 - Local data persistence
- **provider**: v6.1.2 - State management and dependency injection
- **google_fonts**: v6.2.1 - Access to Google Fonts
- **cupertino_icons**: v1.0.8 - iOS-style icons

### Development Dependencies
- **flutter_test**: SDK - Testing framework
- **flutter_lints**: v6.0.0 - Linting rules for code quality

For a complete list, see `pubspec.yaml`.

## Development Commands

### Code Quality
```bash
# Run analysis
flutter analyze

# Format code
dart format lib/
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Hot Reload / Hot Restart
```bash
# Hot reload (preserves state)
r

# Hot restart (clears state)
R
```

### Building for Release
```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
# or for App Bundle:
flutter build appbundle --release

# Web
flutter build web --release
```

## Troubleshooting

### "flutter: command not found"
- Ensure Flutter SDK is installed and added to PATH
- Run: `echo $PATH` to verify
- Add Flutter to PATH if needed: `export PATH="$PATH:$(flutter config --flutter-root)/bin"`

### "Pod install" fails on iOS
- Clear CocoaPods cache: `rm -rf ios/Pods ios/Podfile.lock`
- Run: `cd ios && pod install && cd ..`

### Build fails with "Permission denied"
```bash
chmod +x ios/Runner/Runner-Bridging-Header.h
chmod +x android/gradlew
```

### Gradle sync issues on Android
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Device not recognized
```bash
flutter clean
flutter doctor --android-licenses  # For Android
flutter devices
```

### API Connection Issues
- Verify the backend API is running and accessible
- Check network connectivity
- Verify the API base URL in service classes matches your backend
- Some endpoints have timeouts (dietary API: 2 seconds) - check server response time

### Preferences Not Persisting
- Ensure SharedPreferences has been initialized: `await SharedPreferences.getInstance()`
- Check that preference keys are not being modified between screens
- Clear app data and reinstall if needed: `flutter clean && flutter pub get`

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Documentation](https://dart.dev/guides)
- [Flutter Packages](https://pub.dev/flutter)
- [State Management with Provider](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://material.io/design)
- [HTTP Package Documentation](https://pub.dev/packages/http)
- [SharedPreferences Documentation](https://pub.dev/packages/shared_preferences)
- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)

## Contributing

For contribution guidelines and pull request procedures, please refer to the project's contribution policy.

## License

This project is private and not intended for public distribution.
