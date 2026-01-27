@echo off
chcp 65001 >nul 2>&1
REM =========================================
REM ML Service Startup Script V2.0 (Windows)
REM =========================================

echo.
echo ========================================
echo   ML Service v2.0 Starting...
echo ========================================
echo.

REM Find Python with fastapi installed
set PYTHON_CMD=python

REM Try python command
python -c "import fastapi" >nul 2>&1
if %errorlevel% equ 0 (
    set PYTHON_CMD=python
    goto :found_python
)

REM Try Python312
if exist "C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe" (
    "C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe" -c "import fastapi" >nul 2>&1
    if %errorlevel% equ 0 (
        set PYTHON_CMD=C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe
        goto :found_python
    )
)

REM Try Python311
if exist "C:\Users\Administrator\AppData\Local\Programs\Python\Python311\python.exe" (
    "C:\Users\Administrator\AppData\Local\Programs\Python\Python311\python.exe" -c "import fastapi" >nul 2>&1
    if %errorlevel% equ 0 (
        set PYTHON_CMD=C:\Users\Administrator\AppData\Local\Programs\Python\Python311\python.exe
        goto :found_python
    )
)

REM Python not found or fastapi not installed
echo [ERROR] Cannot find Python with FastAPI installed!
echo.
echo Please install dependencies first:
echo   pip install -r requirements.txt
echo.
pause
exit /b 1

:found_python
echo [1/4] Python environment... OK
echo Using: %PYTHON_CMD%

REM Install dependencies with the correct Python
echo [2/4] Installing dependencies...
"%PYTHON_CMD%" -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple -q
echo [2/4] Dependencies... OK

REM Check config
echo [3/4] Checking config...
if not exist "config.env" (
    echo [WARNING] config.env not found
    if exist "config.env.example" (
        copy config.env.example config.env >nul
    )
)
echo [3/4] Config... OK

REM Create directories
echo [4/4] Initializing directories...
if not exist "logs" mkdir logs
if not exist "models\saved" mkdir models\saved
if not exist "models\trained" mkdir models\trained
echo [4/4] Directories... OK

echo.
echo ========================================
echo   Starting ML Service...
echo   URL: http://localhost:8001
echo   API Docs: http://localhost:8001/docs
echo ========================================
echo.

REM Start service with correct Python
"%PYTHON_CMD%" main_service.py

pause
