# Build and Run

## Toolchain

Required:
- Flutter stable
- Dart bundled with Flutter
- JDK 17
- Android SDK with API 35
- Android platform tools / adb
- Gradle wrapper generated for `app/android` if the wrapper JAR is not already present locally

Garmin integration dependency:
- `com.garmin.connectiq:ciq-companion-app-sdk:2.4.0@aar`

## First checkout

```powershell
cd app
flutter pub get

cd ..\packages\domain
dart pub get
dart test
dart analyze

cd ..\..\app
flutter analyze
flutter test
```

## Android wrapper bootstrap

The repository stores wrapper configuration but does not commit a generated binary `gradle-wrapper.jar` from this execution environment.

If `app/android/gradle/wrapper/gradle-wrapper.jar` is absent:

```powershell
cd app\android
gradle wrapper --gradle-version 8.10.2
cd ..
```

Then:

```powershell
flutter build apk --debug
flutter run
```

## Simulation mode

1. complete onboarding/setup
2. Settings -> Developer simulation mode
3. select NearSentry Simulator
4. arm
5. Diagnostics -> inject disconnect/recovery/degraded/alarm/serviceRestart

Simulation is not Garmin evidence.

## Real Garmin

1. install/update Garmin Connect
2. pair/connect the Garmin normally
3. grant NearSentry required permissions
4. open setup and select the Garmin exposed by Connect IQ
5. arm while watch is present
6. execute the hardware validation matrix

## Diagnostics

Use the in-app Diagnostics/Event History plus:

```powershell
adb logcat | Select-String "NearSentry|ConnectIQ"
```
