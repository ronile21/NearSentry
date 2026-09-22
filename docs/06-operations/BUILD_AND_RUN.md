# Build and Run

Version 0.0.0.1 is a repository skeleton, not yet a complete generated Flutter/Android application.

## Prerequisites

- Flutter stable SDK
- Android Studio / Android SDK
- JDK version supported by the selected Flutter/Gradle toolchain

## Initial workflow

```powershell
flutter --version
dart --version
cd packages/domain
dart pub get
dart test
```

The app/native build procedure will be finalized when the Android wrapper and Kotlin service module are implemented.

## Rule

Do not claim background reliability from emulator-only testing. Real Android hardware is mandatory.
