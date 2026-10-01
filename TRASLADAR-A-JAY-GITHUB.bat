@echo off
title Trasladar Flow-R2 a jayurbano24/flow-r2 (para Vercel)
cd /d "%~dp0"
set "PATH=C:\Program Files\Git\bin;C:\Program Files\Git\cmd;%PATH%"

where git >nul 2>&1
if errorlevel 1 (
  echo Instale Git: winget install Git.Git
  pause
  exit /b 1
)

set "JAY_URL=https://github.com/jayurbano24/UrbanoTCW24-flow-r2.git"

echo.
echo  Este script sube la rama main LOCAL a jayurbano24/flow-r2
echo  (mismo codigo que UrbanoTCW24/flow-r2, commit 02e9233+).
echo.
echo  ANTES: en GitHub como jayurbano24 cree el repo "flow-r2"
echo        (privado OK). No hace falta README si va vacio.
echo.

git remote remove jay 2>nul
git remote add jay "%JAY_URL%"
git fetch jay 2>nul

echo Remotos:
git remote -v
echo.
echo Ultimo commit local:
git log -1 --oneline
echo.

set /p OK=¿Push a jayurbano24/flow-r2 main? (S/N): 
if /i not "%OK%"=="S" exit /b 0

git push -u jay main
if errorlevel 1 (
  echo.
  echo Push rechazado. Si el repo de Jay tiene otro historial ^(Initial commit^):
  echo   git push jay main --force-with-lease
  echo Solo si estas seguro de reemplazar lo que hay en Jay.
  pause
  exit /b 1
)

echo.
echo OK. En Vercel ^(proyecto flow-r2^): Redeploy o espera hook automatico.
echo Commit esperado en deploy: 02e9233 o dd1a912
echo URL lab: https://flow-r2.vercel.app
echo.
pause
