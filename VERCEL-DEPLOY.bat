@echo off
title ITAD Core - Deploy Vercel
cd /d "%~dp0"
set "PATH=C:\Program Files\nodejs;%PATH%"

where node >nul 2>&1
if errorlevel 1 (
  echo Node.js no esta en C:\Program Files\nodejs
  echo Instale con: winget install OpenJS.NodeJS.LTS
  echo Luego cierre Cursor por completo y vuelva a abrirlo.
  pause
  exit /b 1
)

echo Node: 
node -v
echo npm:
call npm -v
echo.
echo --- Paso 1: login (solo la primera vez) ---
call npx --yes vercel login
echo.
echo --- Paso 2: deploy ---
echo Antes en vercel.com agregue ITAD_SUPABASE_URL e ITAD_SUPABASE_ANON_KEY
echo.
call npx --yes vercel --prod
pause
