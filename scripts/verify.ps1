$ErrorActionPreference = "Stop"

Write-Host "NearSentry verification"

$version = (Get-Content "VERSION" -Raw).Trim()
Write-Host "Version: $version"

if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
    throw "Dart is not available on PATH"
}

Push-Location "packages/domain"
try {
    dart pub get
    dart format --output=none --set-exit-if-changed .
    dart analyze
    dart test
}
finally {
    Pop-Location
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter is not available on PATH"
}

Push-Location "app"
try {
    flutter pub get
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test

    $wrapperJar = Join-Path "android" "gradle/wrapper/gradle-wrapper.jar"
    if (Test-Path $wrapperJar) {
        flutter build apk --debug
    }
    else {
        Write-Warning "Gradle wrapper JAR is absent; run scripts/bootstrap-android-wrapper.ps1, then flutter build apk --debug."
    }
}
finally {
    Pop-Location
}

Write-Host "NearSentry verification completed."
