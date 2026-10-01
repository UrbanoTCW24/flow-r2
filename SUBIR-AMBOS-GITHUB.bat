@echo off
title Subir Flow-R2 a Urbano + fork Jay (Vercel)
cd /d "%~dp0"
set "PATH=C:\Program Files\Git\bin;C:\Program Files\Git\cmd;%PATH%"

where git >nul 2>&1
if errorlevel 1 (
  echo Instale Git: winget install Git.Git
  pause
  exit /b 1
)

set "ORIGIN=https://github.com/UrbanoTCW24/flow-r2.git"
set "JAY_FORK=https://github.com/jayurbano24/UrbanoTCW24-flow-r2.git"

git remote remove origin 2>nul
git remote add origin "%ORIGIN%" 2>nul
git remote set-url origin "%ORIGIN%"

git remote remove jay 2>nul
git remote add jay "%JAY_FORK%" 2>nul
git remote set-url jay "%JAY_FORK%"

echo.
echo Remotos:
git remote -v
echo.
git add -A
git status
echo.
git commit -m "ITAD Flow-R2: actualizacion lab" 2>nul
if errorlevel 1 echo (sin commit nuevo - OK si no hubo cambios)
echo.
echo --- Push UrbanoTCW24 (origin) ---
git push -u origin main
echo.
echo --- Push fork Jay (Vercel) - login jayurbano24 + token si pide ---
git push -u jay main
if errorlevel 1 (
  echo.
  echo Si falla: use credenciales de jayurbano24 o solo conecte Vercel al fork en la web.
  echo Fork ya tiene los commits si hizo Fork desde GitHub.
)
echo.
pause
