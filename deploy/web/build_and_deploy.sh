#!/usr/bin/env bash
# Compila Flutter Web apuntando al proxy serverless de Vercel (en vez del
# localhost:8787 de desarrollo) y copia el resultado a deploy/web/public,
# listo para `vercel --prod` desde esta carpeta (deploy/web).
set -uo pipefail
cd "$(dirname "$0")/../.."

# El wrapper flutter.bat en Windows a veces devuelve un exit code distinto
# de 0 aunque el build sí haya terminado bien (ruido de telemetría), así
# que se verifica éxito por la presencia de index.html en vez del $?.
#
# MSYS_NO_PATHCONV=1 es crítico: sin esto, Git Bash convierte
# automáticamente "/api/deezer" (por empezar con "/") en una ruta de
# Windows tipo "C:/Program Files/Git/api/deezer" antes de pasárselo a
# flutter — el build "funciona" pero queda con la URL del proxy rota
# horneada adentro, y solo se nota probando la app real en un navegador
# (curl a la API no lo detecta).
#
# --wasm: el compilador JS por defecto tiene un bug real con el renderer
# CanvasKit donde, al volver de una pantalla de detalle (álbum/artista/
# reproductor) hacia una ruta que se mantuvo montada debajo (el patrón de
# shell con Navigator anidado de AppShell), las imágenes dejan de pintarse
# ("WebGL: INVALID_VALUE: texImage2D: no image" en bucle). El pipeline de
# compilación a WebAssembly no tiene este problema — verificado a mano en
# el navegador repitiendo el flujo que lo rompía.
MSYS_NO_PATHCONV=1 flutter build web --release --wasm --dart-define=DEEZER_PROXY_BASE_URL=/api/deezer
if [ ! -f build/web/index.html ]; then
  echo "El build falló: no se generó build/web/index.html" >&2
  exit 1
fi

rm -rf deploy/web/public
mkdir -p deploy/web/public
cp -r build/web/. deploy/web/public/

echo "Listo. Ahora corre:"
echo "  cd deploy/web && vercel --prod"
