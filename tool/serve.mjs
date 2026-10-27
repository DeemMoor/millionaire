// Local preview server for build/web: gzip + cross-origin isolation headers,
// so skwasm can run multi-threaded.
// Usage: node tool/serve.mjs [port]
import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { gzipSync } from 'node:zlib';

const root = new URL('../build/web/', import.meta.url).pathname;
const port = Number(process.argv[2] ?? 8790);
const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript',
  '.mjs': 'text/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
};
const gzipCache = new Map();

createServer(async (req, res) => {
  let path = normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname));
  if (path.endsWith('/')) path += 'index.html';
  const file = join(root, path);
  if (!file.startsWith(root)) return res.writeHead(403).end();
  let body, mtime;
  try {
    [body, { mtimeMs: mtime }] = await Promise.all([readFile(file), stat(file)]);
  } catch {
    return res.writeHead(404).end();
  }
  const headers = {
    'Content-Type': types[extname(file)] ?? 'application/octet-stream',
    'Cross-Origin-Opener-Policy': 'same-origin',
    'Cross-Origin-Embedder-Policy': 'require-corp',
    'Cache-Control': 'no-cache',
  };
  if (/\bgzip\b/.test(req.headers['accept-encoding'] ?? '') && body.length > 1024) {
    const key = `${file}:${mtime}`;
    if (!gzipCache.has(key)) gzipCache.set(key, gzipSync(body));
    body = gzipCache.get(key);
    headers['Content-Encoding'] = 'gzip';
  }
  res.writeHead(200, headers).end(body);
}).listen(port, '127.0.0.1', () => console.log(`http://localhost:${port}`));
