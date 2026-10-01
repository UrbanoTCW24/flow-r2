/* eslint-disable no-restricted-globals */
/** Preprocesado OCR (contraste/invert) fuera del main thread — OffscreenCanvas */

async function canvasToBlob(canvas, quality) {
  if (canvas.convertToBlob) {
    return canvas.convertToBlob({ type: 'image/jpeg', quality });
  }
  return null;
}

async function bitmapToJpegBlob(bitmap, quality) {
  const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
  const ctx = canvas.getContext('2d', { alpha: false });
  ctx.drawImage(bitmap, 0, 0);
  return canvasToBlob(canvas, quality);
}

async function downscaleBitmap(bitmap, cap) {
  let w = bitmap.width;
  let h = bitmap.height;
  if (Math.max(w, h) <= cap) return bitmap;
  const scale = cap / Math.max(w, h);
  w = Math.round(w * scale);
  h = Math.round(h * scale);
  const canvas = new OffscreenCanvas(w, h);
  canvas.getContext('2d', { alpha: false }).drawImage(bitmap, 0, 0, w, h);
  bitmap.close();
  const blob = await canvasToBlob(canvas, 0.85);
  return createImageBitmap(blob);
}

function detectDarkLabel(bitmap) {
  const sw = Math.min(bitmap.width, 320);
  const sh = Math.min(bitmap.height, 240);
  const canvas = new OffscreenCanvas(sw, sh);
  const ctx = canvas.getContext('2d', { alpha: false });
  ctx.drawImage(bitmap, 0, 0, sw, sh);
  const sample = ctx.getImageData(0, 0, sw, sh);
  let sum = 0;
  for (let i = 0; i < sample.data.length; i += 4) {
    sum += 0.299 * sample.data[i] + 0.587 * sample.data[i + 1] + 0.114 * sample.data[i + 2];
  }
  return sum / (sample.data.length / 4) < 115;
}

function renderVariant(bitmap, w, h, invert, contrast) {
  const canvas = new OffscreenCanvas(w, h);
  const ctx = canvas.getContext('2d', { alpha: false });
  ctx.drawImage(bitmap, 0, 0, w, h);
  const img = ctx.getImageData(0, 0, w, h);
  for (let i = 0; i < img.data.length; i += 4) {
    let g = 0.299 * img.data[i] + 0.587 * img.data[i + 1] + 0.114 * img.data[i + 2];
    if (invert) g = 255 - g;
    g = Math.min(255, Math.max(0, (g - 128) * contrast + 128));
    img.data[i] = img.data[i + 1] = img.data[i + 2] = g;
  }
  ctx.putImageData(img, 0, 0);
  return canvas;
}

self.onmessage = async (event) => {
  const { id, bitmap, maxPx, maxVariants, quality } = event.data || {};
  if (!bitmap) {
    self.postMessage({ id, ok: false, error: 'NO_BITMAP' });
    return;
  }
  try {
    let bm = bitmap;
    bm = await downscaleBitmap(bm, maxPx || 720);
    const w = bm.width;
    const h = bm.height;
    const darkLabel = detectDarkLabel(bm);
    const maxV = Math.max(1, Math.min(3, maxVariants || 1));
    const specs = darkLabel
      ? [[true, 1.45], [true, 1.2], [false, 1.25]]
      : [[false, 1.25], [true, 1.35]];
    const picked = specs.slice(0, maxV);
    const buffers = [];
    for (const [invert, contrast] of picked) {
      const canvas = renderVariant(bm, w, h, invert, contrast);
      const blob = await canvasToBlob(canvas, quality ?? 0.78);
      if (!blob) continue;
      buffers.push(await blob.arrayBuffer());
    }
    bm.close();
    self.postMessage({ id, ok: true, buffers }, buffers);
  } catch (err) {
    try { bitmap.close(); } catch (_) { /* ignore */ }
    self.postMessage({ id, ok: false, error: String(err?.message || err) });
  }
};
