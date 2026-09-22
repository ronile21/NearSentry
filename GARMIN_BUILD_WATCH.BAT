@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

set "EXPECTED_BRANCH=v0.0.0.1"
set "WATCH_DIR=%CD%\watch\garmin"
set "BUILD_DIR=%WATCH_DIR%\build"
set "LOCAL_KEY=%WATCH_DIR%\developer_key.der"
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
    echo [ERROR] Garmin Connect IQ active SDK is not configured.
    echo.
    echo Expected:
    echo   %SDK_CFG%
    echo.
    echo Open Garmin Connect IQ SDK Manager, install an SDK and set it Active.
    exit /b 1
)

set /p "CIQ_HOME="<"%SDK_CFG%"
if "%CIQ_HOME:~-1%"=="\" set "CIQ_HOME=%CIQ_HOME:~0,-1%"

echo [INFO] Active Connect IQ SDK:
echo        %CIQ_HOME%
echo.

rem Connect IQ SDK layouts differ between releases.
rem SDK 9.2.0 on Windows exposes monkeyc.bat in the SDK root.
set "MONKEYC="
if exist "%CIQ_HOME%\monkeyc.bat" set "MONKEYC=%CIQ_HOME%\monkeyc.bat"
if not defined MONKEYC if exist "%CIQ_HOME%\bin\monkeyc.bat" set "MONKEYC=%CIQ_HOME%\bin\monkeyc.bat"
if not defined MONKEYC if exist "%CIQ_HOME%\monkeyc" set "MONKEYC=%CIQ_HOME%\monkeyc"
if not defined MONKEYC if exist "%CIQ_HOME%\bin\monkeyc" set "MONKEYC=%CIQ_HOME%\bin\monkeyc"

if not defined MONKEYC (
    echo [ERROR] monkeyc was not found in the active Connect IQ SDK.
    echo.
    echo Checked:
    echo   %CIQ_HOME%\monkeyc.bat
    echo   %CIQ_HOME%\bin\monkeyc.bat
    echo.
    exit /b 1
)

echo [INFO] Compiler:
echo        %MONKEYC%
echo.

set "KEY_DER="

rem 1. Project-local key expected by NearSentry.
if exist "%LOCAL_KEY%" set "KEY_DER=%LOCAL_KEY%"

rem 2. Optional explicit key supplied by the developer.
if not defined KEY_DER if defined CIQ_DEVELOPER_KEY (
    if exist "%CIQ_DEVELOPER_KEY%" set "KEY_DER=%CIQ_DEVELOPER_KEY%"
)

if not defined KEY_DER (
    echo [ERROR] Garmin developer signing key was not found.
    echo.
    echo The Garmin Monkey C VS Code extension is the easiest supported way
    echo to create one. In VS Code:
    echo.
    echo   1. Restart VS Code after installing the Garmin Monkey C extension.
    echo   2. Press Ctrl+Shift+P.
    echo   3. Run: Monkey C: Generate a Developer Key
    echo   4. Save the key exactly as:
    echo.
    echo      %LOCAL_KEY%
    echo.
    echo Then run this BAT again.
    echo.
    echo Alternative: set CIQ_DEVELOPER_KEY to an existing Garmin key file.
    exit /b 1
)

echo [INFO] Developer key:
echo        %KEY_DER%
echo.

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
echo  SDK:
echo  %CIQ_HOME%
echo.
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
