@echo off
echo Starting ML Test Server...
cd /d "%~dp0"
py test_server.py
pause
