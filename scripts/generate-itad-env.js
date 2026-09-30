/**
 * Genera itad-env.js en build (Vercel) con variables de entorno.
 * La anon key es pública por diseño (RLS en Supabase).
 */
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const url =
  process.env.ITAD_SUPABASE_URL ||
  process.env.NEXT_PUBLIC_SUPABASE_URL ||
  'https://fmqtkuyefbawfpeijjnq.supabase.co';
const key =
  process.env.ITAD_SUPABASE_ANON_KEY ||
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
  '';

const cfg = {
  supabaseUrl: url.trim(),
  supabaseAnonKey: key.trim(),
  bucketPhotos: (process.env.ITAD_BUCKET_PHOTOS || 'itad-photos').trim(),
  bucketPdfs: (process.env.ITAD_BUCKET_PDFS || 'itad-pdfs').trim()
};

const js = `// Auto-generado en deploy — no editar a mano en producción
window.__ITAD_RUNTIME_CONFIG__ = ${JSON.stringify(cfg, null, 2)};
`;

fs.writeFileSync(path.join(root, 'itad-env.js'), js, 'utf8');
console.log('[ITAD] itad-env.js generado (Supabase URL:', cfg.supabaseUrl, ', key:', cfg.supabaseAnonKey ? '***' : 'vacía', ')');
if (process.env.VERCEL && !cfg.supabaseAnonKey) {
  console.warn(
    '[ITAD] AVISO: ITAD_SUPABASE_ANON_KEY no está en Vercel. Añádala en Project Settings → Environment Variables (Production) y Redeploy.'
  );
}
