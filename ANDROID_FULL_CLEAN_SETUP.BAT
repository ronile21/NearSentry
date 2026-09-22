@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "APP_DIR=%CD%\app"
set "DOMAIN_DIR=%CD%\packages\domain"
set "PACKAGE_ID=com.nearsentry.app"
set "APK_PATH=%APP_DIR%\build\app\outputs\flutter-apk\app-debug.apk"

echo.
echo ============================================================
echo  NearSentry - ANDROID FULL CLEAN SETUP
echo ============================================================
echo.

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

echo [1/8] Stopping and removing existing NearSentry installation...
adb shell am force-stop %PACKAGE_ID% >nul 2>&1
adb uninstall %PACKAGE_ID% >nul 2>&1
echo       Existing installation removed or was not installed.

echo.
echo [2/8] Cleaning Flutter and generated project artifacts...
pushd "%APP_DIR%"
call flutter clean
if errorlevel 1 goto :fail
popd

if exist "%CD%\build" rmdir /s /q "%CD%\build"
if exist "%APP_DIR%\build" rmdir /s /q "%APP_DIR%\build"
if exist "%APP_DIR%\.dart_tool" rmdir /s /q "%APP_DIR%\.dart_tool"
if exist "%APP_DIR%\android\.gradle" rmdir /s /q "%APP_DIR%\android\.gradle"
if exist "%DOMAIN_DIR%\.dart_tool" rmdir /s /q "%DOMAIN_DIR%\.dart_tool"

echo.
echo [3/8] Restoring domain dependencies...
pushd "%DOMAIN_DIR%"
call dart pub get
if errorlevel 1 goto :fail_pop
popd

echo.
echo [4/8] Restoring Flutter dependencies...
pushd "%APP_DIR%"
call flutter pub get
if errorlevel 1 goto :fail_pop
popd

echo.
echo [5/8] Ensuring Android Gradle wrapper exists...
if not exist "%APP_DIR%\android\gradlew.bat" (
    where gradle >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Android Gradle wrapper is missing and global Gradle is not available.
        echo         Install Gradle 8.x or generate the wrapper once from Android Studio.
        echo         Expected file: %APP_DIR%\android\gradlew.bat
        exit /b 1
    )

    pushd "%APP_DIR%\android"
    call gradle wrapper --gradle-version 8.10.2
    if errorlevel 1 goto :fail_pop
    popd
)

echo.
echo [6/8] Cleaning Android Gradle build...
pushd "%APP_DIR%\android"
call gradlew.bat clean --no-daemon
if errorlevel 1 goto :fail_pop
popd

echo.
echo [7/8] Building fresh Android debug APK...
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
echo [8/8] Installing APK on the connected Android device...
adb install -r -d "%APK_PATH%"
if errorlevel 1 goto :fail

echo.
echo Launching NearSentry...
adb shell am start -n %PACKAGE_ID%/.MainActivity
if errorlevel 1 goto :fail

echo.
echo ============================================================
echo  SUCCESS
echo ============================================================
echo  APK:
echo  %APK_PATH%
echo.
echo  Package:
echo  %PACKAGE_ID%
echo.
echo  NearSentry was rebuilt, installed and launched.
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
echo  Review the error output above.
echo ============================================================
echo.
exit /b 1
