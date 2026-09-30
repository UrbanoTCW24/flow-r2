@echo off
title ITAD - Permiso Wi-Fi (una sola vez)
cd /d "%~dp0"
net session >nul 2>&1
if errorlevel 1 (
  echo Ejecute como ADMINISTRADOR: clic derecho en este archivo.
  pause
  exit /b 1
)
echo Registrando puertos 8888 y 9090 para acceso desde telefono...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve-itad.ps1" -RegisterUrl -Port 8888
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve-itad.ps1" -RegisterUrl -Port 9090
echo.
echo Listo. Ahora puede usar INICIAR-ITAD-TELEFONO.bat sin ser admin.
pause
