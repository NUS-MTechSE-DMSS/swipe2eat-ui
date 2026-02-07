# Swipe2Eat UI

A Flutter application for discovering and saving food items through an intuitive swipe-based interface.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

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
- **provider**: State management (v6.1.2)
- **google_fonts**: Custom fonts support (v6.2.1)
- **cupertino_icons**: iOS-style icons (v1.0.8)

### 4. (iOS Only) Install iOS Pods

```bash
cd ios
pod install
cd ..
```

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
├── main.dart              # App entry point
├── app.dart               # App configuration
├── core/                  # Core utilities
│   ├── navigation/        # Navigation setup
│   ├── state/             # State management
│   ├── theme/             # Theme configuration
│   └── widgets/           # Reusable widgets
└── features/              # Feature modules
    ├── discover/          # Discovery feature
    ├── favorites/         # Favorites feature
    ├── onboarding/        # Onboarding flow
    └── profile/           # User profile
└── models/                # Data models
    ├── cuisine_option.dart
    └── food_item.dart
```

## Dependencies

### Core Dependencies
- **flutter**: Flutter SDK for UI development
- **provider**: v6.1.2 - State management and dependency injection
- **google_fonts**: v6.2.1 - Access to Google Fonts
- **cupertino_icons**: v1.0.8 - iOS-style icons

### Development Dependencies
- **flutter_test**: SDK - Testing framework
- **flutter_lints**: v6.0.0 - Linting rules for code quality

For a complete list, see `pubspec.yaml`.

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

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Documentation](https://dart.dev/guides)
- [Flutter Packages](https://pub.dev/flutter)
- [State Management with Provider](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://material.io/design)

## Contributing

For contribution guidelines and pull request procedures, please refer to the project's contribution policy.

## License

This project is private and not intended for public distribution.
