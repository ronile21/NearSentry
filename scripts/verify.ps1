$ErrorActionPreference = "Stop"

Write-Host "NearSentry verification"

if (-not (Test-Path "VERSION")) {
    throw "VERSION file is missing"
}

$version = (Get-Content "VERSION" -Raw).Trim()
Write-Host "Version: $version"

Push-Location "packages/domain"
try {
    dart pub get
    dart test
}
finally {
    Pop-Location
}

Write-Host "Repository verification completed."
