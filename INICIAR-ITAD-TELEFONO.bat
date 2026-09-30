@echo off
title ITAD Core - Servidor para telefono (Wi-Fi)
cd /d "%~dp0"

:: HttpListener en la red local suele requerir administrador
net session >nul 2>&1
if errorlevel 1 (
  echo.
  echo  Se necesita ejecutar como ADMINISTRADOR para que el telefono entre por Wi-Fi.
  echo  Clic derecho en este archivo -^> "Ejecutar como administrador"
  echo.
  pause
  exit /b 1
)

echo.
echo  Puerto 8888 - misma Wi-Fi que esta PC
echo  En el TELEFONO use la URL azul "http://192.168.x.x:8888/"
echo  NUNCA use 127.0.0.1 ni localhost en el telefono.
echo  Si falla "Acceso denegado", ejecute una vez REGISTRAR-ITAD-WIFI.bat como admin.
echo  Deje esta ventana ABIERTA.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve-itad.ps1" -AllowLan -Port 8888
pause