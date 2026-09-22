@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

set "EXPECTED_BRANCH=v0.0.0.1"
set "APP_DIR=%CD%\app"
set "DOMAIN_DIR=%CD%\packages\domain"
set "PACKAGE_ID=com.nearsentry.app"
set "APK_PATH=%APP_DIR%\build\app\outputs\flutter-apk\app-debug.apk"

echo.
echo ============================================================
echo  NearSentry v0.0.0.1 - ANDROID FULL CLEAN SETUP
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

where dart >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Dart is not available on PATH.
    exit /b 1
)

where adb >nul 2>&1
if errorlevel 1 (
    echo [ERROR] adb is not available on PATH.
    exit /b 1
)

where java >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Java is not available on PATH.
    exit /b 1
)

if not exist "%APP_DIR%\pubspec.yaml" (
    echo [ERROR] Flutter application was not found at:
    echo         %APP_DIR%
    exit /b 1
)

echo [1/8] Verifying the directly connected Android device...
adb get-state >nul 2>&1
if errorlevel 1 (
    echo [ERROR] The connected Android device is not authorized or not available to ADB.
    echo.
    echo Unlock the phone and approve:
    echo   Allow USB debugging
    echo.
    echo Then run this BAT again.
    exit /b 1
)
echo       ADB device is authorized.

echo.
echo [2/8] Stopping and removing existing NearSentry installation...
adb shell am force-stop %PACKAGE_ID% >nul 2>&1
adb uninstall %PACKAGE_ID% >nul 2>&1
echo       Existing installation removed or was not installed.

echo.
echo [3/8] Performing full local clean...
pushd "%APP_DIR%"
call flutter clean
if errorlevel 1 goto :fail_pop
popd

if exist "%CD%\build" rmdir /s /q "%CD%\build"
if exist "%APP_DIR%\build" rmdir /s /q "%APP_DIR%\build"
if exist "%APP_DIR%\.dart_tool" rmdir /s /q "%APP_DIR%\.dart_tool"
if exist "%APP_DIR%\android\.gradle" rmdir /s /q "%APP_DIR%\android\.gradle"
if exist "%DOMAIN_DIR%\.dart_tool" rmdir /s /q "%DOMAIN_DIR%\.dart_tool"

echo.
echo [4/8] Restoring domain dependencies...
pushd "%DOMAIN_DIR%"
call dart pub get
if errorlevel 1 goto :fail_pop
popd

echo.
echo [5/8] Running domain validation...
pushd "%DOMAIN_DIR%"
call dart analyze
if errorlevel 1 goto :fail_pop
call dart test
if errorlevel 1 goto :fail_pop
popd

echo.
echo [6/8] Restoring and validating Flutter application...
pushd "%APP_DIR%"
call flutter pub get
if errorlevel 1 goto :fail_pop
call flutter analyze
if errorlevel 1 goto :fail_pop
call flutter test
if errorlevel 1 goto :fail_pop
popd

echo.
echo [7/8] Building a completely fresh Android debug APK...
pushd "%APP_DIR%"
call flutter build apk --debug
if errorlevel 1 goto :fail_pop
popd

if not exist "%APK_PATH%" (
    echo [ERROR] Build completed but APK was not found:
    echo         %APK_PATH%
    exit /b 1
)

echo.
echo [8/8] Installing and launching NearSentry...
adb install -r -d "%APK_PATH%"
if errorlevel 1 goto :fail

adb shell am force-stop %PACKAGE_ID% >nul 2>&1
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
echo  NearSentry was cleaned, validated, rebuilt, installed,
echo  and launched on the connected Android device.
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
echo  NearSentry full clean setup failed.
echo  Review the FIRST error above. Later errors may be cascading.
echo ============================================================
echo.
exit /b 1
