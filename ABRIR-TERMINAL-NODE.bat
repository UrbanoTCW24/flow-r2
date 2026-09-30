@echo off
title PowerShell con Node.js en PATH
set "PATH=C:\Program Files\nodejs;%PATH%"
cd /d "%~dp0"
echo Node listo en esta ventana:
node -v
echo.
echo Ejemplos:
echo   npx vercel login
echo   npx vercel
echo   npm run build
echo.
cmd /k
