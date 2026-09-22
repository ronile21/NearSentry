# Developer Guide

## Repository

Long-lived development branch: `develop`.

## Setup

```powershell
flutter doctor -v
java -version
adb version

cd packages\domain
dart pub get

cd ..\..\app
flutter pub get
```

## Verification

```powershell
cd packages\domain
dart format --output=none --set-exit-if-changed .
dart analyze
dart test

cd ..\..\app
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Architecture debugging

Protection truth comes from Android native snapshots, not widget state.

Inspect:
- service health
- runtime generation
- normalized anchor status
- transition journal
- simulation flag

## Garmin SDK

The Android native module depends on Garmin's Connect IQ Companion App SDK from Maven. Garmin Connect must be installed/available on a real test phone for production adapter testing.

The first detector uses device status events and does not require a custom watch app.

## Foreground service

When armed, verify:

```powershell
adb shell dumpsys activity services com.nearsentry.app
adb shell dumpsys notification --noredact
```

## Alarm

Test:
- foreground/background
- screen locked
- full-screen intent allowed/denied
- sound enabled/disabled
- vibration enabled/disabled
- BiometricPrompt/device credential
- repeated alarm events remain idempotent

## Telemetry

Open Event History for human-readable transitions and Diagnostics for current runtime state. No telemetry is uploaded.

## Release rule

Do not call the Garmin path production-verified until the physical-device matrix and soak criteria in `docs/04-testing/` are complete.
