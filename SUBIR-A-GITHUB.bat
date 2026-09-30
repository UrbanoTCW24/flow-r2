@echo off
title Subir Flow-R2 a GitHub
cd /d "%~dp0"
set "PATH=C:\Program Files\Git\bin;C:\Program Files\Git\cmd;%PATH%"
set "REPO_URL=https://github.com/UrbanoTCW24/flow-r2.git"

where git >nul 2>&1
if errorlevel 1 (
  echo.
  echo  Instale Git primero (Administrador):
  echo    winget install Git.Git
  echo  Acepte el instalador, cierre Cursor, vuelva a ejecutar este .bat
  echo.
  echo  Repo destino: %REPO_URL%
  pause
  exit /b 1
)

if not exist ".git" (
  git init -b main
)

git remote remove origin 2>nul
git remote add origin "%REPO_URL%"
git add -A
git status
echo.
git diff --cached --stat
echo.
git commit -m "ITAD Core: recepcion, Supabase, Vercel" 2>nul
if errorlevel 1 (
  echo Sin cambios nuevos o ya commiteado.
)
git branch -M main
echo.
echo Enviando a %REPO_URL% ...
git push -u origin main
if errorlevel 1 (
  echo.
  echo Si pide login: use GitHub Personal Access Token como password
  echo https://github.com/settings/tokens
)
echo.
pause
