$ErrorActionPreference = "Stop"

if (-not (Get-Command gradle -ErrorAction SilentlyContinue)) {
    throw "Gradle is not available on PATH. Install Gradle 8.x or generate the wrapper from Android Studio."
}

Push-Location "app/android"
try {
    gradle wrapper --gradle-version 8.10.2
}
finally {
    Pop-Location
}

Write-Host "Gradle wrapper generated."
