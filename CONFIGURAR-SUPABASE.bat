@echo off
title ITAD - Configurar Supabase
cd /d "%~dp0"
echo.
echo  1) Se abrira el dashboard para copiar la ANON public key
echo  2) Se creara itad-config.local.json si no existe
echo  3) Pegue la key en supabaseAnonKey y guarde
echo  4) Reinicie serve-itad y recargue la app (Ctrl+F5)
echo.
if not exist "itad-config.local.json" (
  copy /Y "itad-config.example.json" "itad-config.local.json" >nul
  echo  Creado itad-config.local.json
)
start "" "https://supabase.com/dashboard/project/fmqtkuyefbawfpeijjnq/settings/api"
notepad "itad-config.local.json"
pause
