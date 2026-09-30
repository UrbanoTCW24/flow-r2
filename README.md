# flow-r2 · ITAD Core

Recepción en sitio, custodia, sanitización y certificación (HTML + Supabase + Storage).

## Lab local

- `serve-itad.cmd` o `INICIAR-ITAD-PC.bat` — PC
- `INICIAR-ITAD-TELEFONO.bat` — misma Wi‑Fi (admin + `REGISTRAR-ITAD-WIFI.bat` una vez)
- `CONFIGURAR-SUPABASE.bat` — anon key local (`itad-config.local.json`, no se sube a git)

## Deploy Vercel

Variables: `ITAD_SUPABASE_URL`, `ITAD_SUPABASE_ANON_KEY`  
Build: `npm run build` → genera `itad-env.js`

## Supabase

SQL en `supabase/` (001–003). Proyecto: `fmqtkuyefbawfpeijjnq`.
