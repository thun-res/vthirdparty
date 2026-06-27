@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SRC_DIR=%SCRIPT_DIR%prebuilt-win32"
if "%VKIT_PREBUILT_DIR%"=="" (
    echo [ERROR] VKIT_PREBUILT_DIR environment variable is not set
    exit /b 1
)
if not exist "%SRC_DIR%" (
    echo [ERROR] Source directory does not exist: %SRC_DIR%
    exit /b 1
)

echo Copying files from:
echo   %SRC_DIR%
echo To:
echo   %VKIT_PREBUILT_DIR%
if not exist "%VKIT_PREBUILT_DIR%" (
    mkdir "%VKIT_PREBUILT_DIR%"
)
xcopy "%SRC_DIR%\*" "%VKIT_PREBUILT_DIR%\" /E /I /Y >nul
if %ERRORLEVEL% LEQ 4 (
    echo [DONE] Files copied successfully
    exit /b 0
) else (
    echo [ERROR] Copy failed, xcopy returned code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

endlocal
