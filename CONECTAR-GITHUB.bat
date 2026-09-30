@echo off
title ITAD Core - Conectar GitHub
cd /d "%~dp0"
set "PATH=C:\Program Files\Git\bin;C:\Program Files\Git\cmd;C:\Program Files\nodejs;%PATH%"

where git >nul 2>&1
if errorlevel 1 (
  echo.
  echo  Git no esta instalado o falta aceptar el instalador (Admin).
  echo  Instale con: winget install Git.Git
  echo  Luego cierre Cursor y vuelva a ejecutar este archivo.
  echo.
  pause
  exit /b 1
)

if not exist ".git" (
  echo Inicializando repositorio...
  git init -b main
)

git status
echo.
echo === SIGUIENTE PASO (GitHub web) ===
echo 1) https://github.com/new  - crear repo vacio (sin README)
echo 2) Copie la URL HTTPS del repo
echo 3) Peguela abajo cuando se pida
echo.
set "REPO_URL=https://github.com/UrbanoTCW24/flow-r2.git"
echo Repo: %REPO_URL%
set /p REPO_URL="Enter para usar esa URL o pegue otra: "
if "%REPO_URL%"=="" set "REPO_URL=https://github.com/UrbanoTCW24/flow-r2.git"
if "%REPO_URL%"=="" (
  echo Cancelado.
  pause
  exit /b 0
)

git add -A
git commit -m "ITAD Core: recepcion, Supabase, deploy Vercel" 2>nul
git branch -M main
git remote remove origin 2>nul
git remote add origin "%REPO_URL%"
echo.
echo Enviando a GitHub (pedira usuario/token si hace falta)...
git push -u origin main
echo.
pause
