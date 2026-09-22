@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "EXPECTED_BRANCH=v0.0.0.1"
set "APP_DIR=%CD%\app"
set "PACKAGE_ID=com.nearsentry.app"
set "APK_PATH=%APP_DIR%\build\app\outputs\flutter-apk\app-debug.apk"

echo.
echo ============================================================
echo  NearSentry v0.0.0.1 - BUILD + INSTALL
echo  NO CLEAN / NO UNINSTALL / APP DATA PRESERVED
echo ============================================================
echo.

for /f "delims=" %%B in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%B"
if /i not "%CURRENT_BRANCH%"=="%EXPECTED_BRANCH%" (
    echo [ERROR] Wrong Git branch.
    echo         Current : %CURRENT_BRANCH%
    echo         Required: %EXPECTED_BRANCH%
    echo.
    echo Run:
    echo   git checkout %EXPECTED_BRANCH%
    echo   git pull --ff-only origin %EXPECTED_BRANCH%
    exit /b 1
)

where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not available on PATH.
    exit /b 1
)

where adb >nul 2>&1
if errorlevel 1 (
    echo [ERROR] adb is not available on PATH.
    exit /b 1
)

if not exist "%APP_DIR%\pubspec.yaml" (
    echo [ERROR] Flutter application was not found at:
    echo         %APP_DIR%
    exit /b 1
)

echo [1/4] Verifying directly connected Android device...
adb get-state >nul 2>&1
if errorlevel 1 (
    echo [ERROR] The connected Android device is unavailable or not authorized.
    echo         Unlock the phone and approve "Allow USB debugging".
    exit /b 1
)
echo       Device is ready.

echo.
echo [2/4] Building debug APK incrementally...
pushd "%APP_DIR%"
call flutter build apk --debug
if errorlevel 1 goto :fail_pop
popd

if not exist "%APK_PATH%" (
    echo [ERROR] APK was not found:
    echo         %APK_PATH%
    exit /b 1
)

echo.
echo [3/4] Installing over the existing NearSentry installation...
adb shell am force-stop %PACKAGE_ID% >nul 2>&1
adb install -r -d "%APK_PATH%"
if errorlevel 1 goto :fail

echo.
echo [4/4] Launching NearSentry...
adb shell am start -n %PACKAGE_ID%/.MainActivity
if errorlevel 1 goto :fail

echo.
echo ============================================================
echo  SUCCESS
echo ============================================================
echo  Branch : %CURRENT_BRANCH%
echo  APK    : %APK_PATH%
echo  Package: %PACKAGE_ID%
echo.
echo  Existing app data was preserved.
echo ============================================================
echo.
exit /b 0

:fail_pop
popd

:fail
echo.
echo ============================================================
echo  FAILED
echo ============================================================
echo  Build/install failed. Review the FIRST error above.
echo ============================================================
echo.
exit /b 1
