// Proxy CORS de producción para Deezer, equivalente serverless a
// tool/cors_proxy.dart (que solo sirve para desarrollo local). Vive en el
// mismo proyecto de Vercel que sirve la app, así que las peticiones desde
// el navegador son same-origin: ni siquiera se necesitaría CORS, pero se
// agrega igual por si se reutiliza este endpoint desde otro origen.
const DEEZER_BASE_URL = 'https://api.deezer.com';

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  // No se usa req.url para la query string: Vercel reescribe internamente
  // las rutas catch-all y le agrega su propio parámetro con el path a
  // req.url/req.query — y, al menos en esta versión del CLI, la clave del
  // catch-all llega literalmente como "...path" (con los puntos incluidos),
  // no "path". Se reconstruye la query a mano quitando esa clave, sea cual
  // sea su nombre exacto.
  const { path: pathKey, '...path': dotsPathKey, ...restQuery } = req.query;
  const segments = pathKey ?? dotsPathKey;
  const targetPath = Array.isArray(segments) ? segments.join('/') : segments || '';
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
