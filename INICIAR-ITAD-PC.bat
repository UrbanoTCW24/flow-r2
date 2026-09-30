@echo off
title ITAD Core - Servidor (esta PC)
cd /d "%~dp0"
echo.
echo  Iniciando ITAD en http://127.0.0.1:8888/
echo  Deje esta ventana ABIERTA. Cierre con Ctrl+C para detener.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve-itad.ps1" -Port 8888
REM Telefono: INICIAR-ITAD-TELEFONO.bat (no use 127.0.0.1 en el movil)
pause
