$ErrorActionPreference = "Stop"

$wrapper = Join-Path $PSScriptRoot "..\app\android\gradlew.bat"
$wrapper = [System.IO.Path]::GetFullPath($wrapper)

if (Test-Path $wrapper) {
    Write-Host "Gradle wrapper already exists:"
    Write-Host $wrapper
    exit 0
}

throw @"
Gradle wrapper is not present in app\android.

NearSentry no longer requires this bootstrap script for the normal Android build.
Use the repository root script instead:

    .\ANDROID_FULL_CLEAN_SETUP.BAT

Flutter will drive the Android build directly.

If you specifically need a standalone Gradle wrapper, generate it from Android Studio
or from a machine with Gradle installed.
"@
