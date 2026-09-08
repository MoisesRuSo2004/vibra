#!/usr/bin/env bash
# Compila Flutter Web apuntando al proxy serverless de Vercel (en vez del
# localhost:8787 de desarrollo) y copia el resultado a deploy/web/public,
# listo para `vercel --prod` desde esta carpeta (deploy/web).
set -uo pipefail
cd "$(dirname "$0")/../.."

# El wrapper flutter.bat en Windows a veces devuelve un exit code distinto
# de 0 aunque el build sí haya terminado bien (ruido de telemetría), así
# que se verifica éxito por la presencia de index.html en vez del $?.
flutter build web --release --dart-define=DEEZER_PROXY_BASE_URL=/api/deezer
if [ ! -f build/web/index.html ]; then
  echo "El build falló: no se generó build/web/index.html" >&2
  exit 1
fi

rm -rf deploy/web/public
mkdir -p deploy/web/public
cp -r build/web/. deploy/web/public/

echo "Listo. Ahora corre:"
echo "  cd deploy/web && vercel --prod"
