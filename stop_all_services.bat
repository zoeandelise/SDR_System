@echo off
title Stop All Services
echo Stopping SDR System Services...
echo Port 8080, 8001, 81, 3000

powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 8080,8001,81,3000 -State Listen -ErrorAction SilentlyContinue | ForEach-Object { Write-Host 'Killing PID: ' $_.OwningProcess; Stop-Process -Id $_.OwningProcess -Force }"

echo All services stopped successfully.
pause
