@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "EXPECTED_BRANCH=v0.0.0.1"
set "WATCH_DIR=%CD%\watch\garmin"
set "BUILD_DIR=%WATCH_DIR%\build"
set "KEY_DER=%WATCH_DIR%\developer_key.der"
set "KEY_PEM=%WATCH_DIR%\developer_key.pem"
set "OUTPUT=%BUILD_DIR%\NearSentry-fenix7x.prg"
set "SDK_CFG=%APPDATA%\Garmin\ConnectIQ\current-sdk.cfg"

echo.
echo ============================================================
echo  NearSentry v0.0.0.1 - GARMIN FENIX 7X BUILD
echo ============================================================
echo.

for /f "delims=" %%B in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%B"
if /i not "%CURRENT_BRANCH%"=="%EXPECTED_BRANCH%" (
    echo [ERROR] Wrong Git branch.
    echo         Current : %CURRENT_BRANCH%
    echo         Required: %EXPECTED_BRANCH%
    exit /b 1
)

if not exist "%SDK_CFG%" (
    echo [ERROR] Garmin Connect IQ SDK is not configured.
    echo.
    echo Install Garmin Connect IQ SDK Manager, download an SDK,
    echo and set it as the current SDK.
    echo Expected configuration:
    echo   %SDK_CFG%
    exit /b 1
)

set /p "CIQ_HOME="<"%SDK_CFG%"
set "MONKEYC=%CIQ_HOME%\bin\monkeyc.bat"
if not exist "%MONKEYC%" set "MONKEYC=%CIQ_HOME%\bin\monkeyc"

if not exist "%MONKEYC%" (
    echo [ERROR] monkeyc was not found under the active Connect IQ SDK:
    echo         %CIQ_HOME%
    exit /b 1
)

if not exist "%KEY_DER%" (
    echo [INFO] No local Garmin developer key found.
    where openssl >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] OpenSSL is not available.
        echo.
        echo Generate a Garmin developer key and place it here:
        echo   %KEY_DER%
        exit /b 1
    )

    echo [INFO] Generating local developer signing key...
    openssl genrsa -out "%KEY_PEM%" 4096
    if errorlevel 1 goto :fail

    openssl pkcs8 -topk8 -inform PEM -outform DER -in "%KEY_PEM%" -out "%KEY_DER%" -nocrypt
    if errorlevel 1 goto :fail
)

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo [1/2] Compiling NearSentry for fenix7x...
pushd "%WATCH_DIR%"
call "%MONKEYC%" -d fenix7x -f monkey.jungle -o "%OUTPUT%" -y "%KEY_DER%"
if errorlevel 1 goto :fail_pop
popd

if not exist "%OUTPUT%" (
    echo [ERROR] monkeyc returned success but PRG does not exist:
    echo         %OUTPUT%
    exit /b 1
)

echo.
echo [2/2] Build complete.
echo.
echo ============================================================
echo  SUCCESS
echo ============================================================
echo  PRG:
echo  %OUTPUT%
echo.
echo  Copy this file to GARMIN\APPS\ on the connected Fenix 7X.
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
echo  Garmin watch build failed. Review the first error above.
echo ============================================================
exit /b 1
