// Proxy CORS de producción para Deezer, equivalente serverless a
// tool/cors_proxy.dart (que solo sirve para desarrollo local). Vive en el
// mismo proyecto de Vercel que sirve la app, así que las peticiones desde
// el navegador son same-origin: ni siquiera se necesitaría CORS, pero se
// agrega igual por si se reutiliza este endpoint desde otro origen.
//
// No es un archivo con corchetes ([...path].js): en este proyecto (sin
// framework detectado por Vercel) el catch-all por convención de archivos
// solo funcionaba para un segmento de ruta (/api/deezer/chart) y devolvía
// 404 con dos o más (/api/deezer/album/123/tracks). En vez de depender de
// esa convención, vercel.json reescribe /api/deezer/:path* hacia este
// archivo plano pasando la ruta completa como query param ?path=...
const DEEZER_BASE_URL = 'https://api.deezer.com';

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  const { path: rawPath, ...restQuery } = req.query;
  const targetPath = Array.isArray(rawPath) ? rawPath.join('/') : rawPath || '';
  const search = new URLSearchParams(restQuery).toString();
  const targetUrl = `${DEEZER_BASE_URL}/${targetPath}${search ? `?${search}` : ''}`;

  try {
    const deezerResponse = await fetch(targetUrl);
    const body = await deezerResponse.text();
    res.setHeader(
      'Content-Type',
      deezerResponse.headers.get('content-type') || 'application/json',
    );
    res.status(deezerResponse.status).send(body);
  } catch (error) {
    res.status(502).send(`Proxy error: ${error.message}`);
  }
};
