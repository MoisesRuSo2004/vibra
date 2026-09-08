# VIBRA 🎧

Aplicación móvil de descubrimiento musical (estilo Spotify) hecha en Flutter, consumiendo la API pública de **Deezer**. Es un taller académico que parte de un código base de consumo de API (originalmente contra Jikan/anime, todo en un único `main.dart`) y lo transforma en una app propia, con arquitectura por capas.

## Índice
- [Consigna del taller](#consigna-del-taller)
- [Cómo cumple este proyecto la consigna](#cómo-cumple-este-proyecto-la-consigna)
- [Arquitectura](#arquitectura)
- [API de Deezer](#api-de-deezer)
- [Manejo de estados](#manejo-de-estados)
- [Pantallas](#pantallas)
- [Cómo correr el proyecto](#cómo-correr-el-proyecto)
- [CORS en Flutter Web](#cors-en-flutter-web-importante)
- [Despliegue](#despliegue)
- [Problemas del despliegue web y cómo se resolvieron](#problemas-del-despliegue-web-y-cómo-se-resolvieron)
- [Estructura de carpetas y clases](#estructura-de-carpetas-y-clases)

## Consigna del taller

Enunciado del profesor (sección Generalidades → Recursos):

> El código proporcionado está en un único archivo `main`, lo cual es una mala práctica. Utilizando los conceptos sobre organización de proyectos en Flutter que estudiamos en clase, debes:
> - Realizar el consumo de la API que seleccionaste.
> - Implementar el diseño de tu mockup.
> - Estructurar y organizar el código de manera profesional.

**Requisitos de entrega:**

1. **Código fuente** — organizado en carpetas y módulos (no en un único archivo). Debe incluir:
   - Separación clara entre capas (presentación, lógica, datos).
   - Archivos de configuración y constantes.
   - Manejo adecuado de errores y estados de carga.
2. **Video explicativo** — mostrando:
   - Funcionamiento de la aplicación.
   - Estructura del código y patrones utilizados.
   - Arquitectura de carpetas y por qué se organizó así.
   - Cómo se integra la API y cómo se manejan las peticiones.
   - Aspectos destacados del diseño implementado.

**Funcionalidades mínimas:** consulta y visualización de datos desde la API, navegación intuitiva entre pantallas, presentación clara de la información. Se invita a agregar creatividad: estilos, animaciones, temas de color, y funciones extra (filtros, búsqueda, favoritos, etc.).

## Cómo cumple este proyecto la consigna

| Requisito del profe | Dónde está resuelto |
|---|---|
| Separación en capas (presentación, lógica, datos) | `presentation/` (UI) → `providers/` (lógica/estado) → `data/repositories/` + `data/services/` (datos), ver [Arquitectura](#arquitectura) |
| Archivos de configuración y constantes | `core/constants/api_constants.dart`, `core/theme/app_theme.dart`, `core/routes/app_routes.dart` |
| Manejo de errores y estados de carga | `enum ViewState` (`providers/view_state.dart`) + widgets `LoadingView`/`ErrorView`/`EmptyView` (`presentation/widgets/state_views.dart`) usados en cada pantalla |
| Consumo de API propia (no la del profe) | Deezer (`https://api.deezer.com`) vía `data/services/music_api_service.dart` — ver [API de Deezer](#api-de-deezer) |
| Implementación del mockup / diseño propio | Tema oscuro estilo Spotify con acento propio (`core/theme/app_theme.dart`), 7 pantallas, transiciones custom, mini-player persistente |
| Navegación intuitiva entre pantallas | `Navigator` anidado + rutas nombradas en `AppShell` (`presentation/screens/app_shell.dart`) + barra inferior de 3 tabs |
| Presentación clara de la información | Modelos tipados 1:1 al JSON de Deezer (`data/models/`), listas/carruseles por sección en cada pantalla |
| Funciones extra (creatividad) | Búsqueda en vivo con debounce, favoritos en memoria, reproductor real de previews de 30s, shuffle/repeat, explorar por género, animaciones fade/slide, "escuchado recientemente" |

## Arquitectura

```
Usuario
  │
  ▼
Screens (presentation/)         → UI, no sabe de HTTP
  │  Provider (ChangeNotifier)
  ▼
MusicProvider / FavoritesProvider / PlayerProvider
  │
  ▼
MusicRepository (data/repositories/)   → traduce JSON crudo a modelos
  │
  ▼
MusicApiService (data/services/)       → llamadas HTTP puras a Deezer
  │
  ▼
Deezer API (https://api.deezer.com)
```

Capas:
- **data/models** — `Artist`, `Album`, `Track`, `Genre`, mapeados 1:1 al JSON real de Deezer.
- **data/services** — `MusicApiService`: únicamente hace `http.get` y decodifica JSON. No conoce Flutter ni el estado de la UI.
- **data/repositories** — `MusicRepository`: punto único por el que la UI pide datos; agrupa/transforma respuestas (p. ej. `getHomeFeed()` arma el Home a partir de `/chart`).
- **providers** — estado de la app con `ChangeNotifier` + `provider`. `MusicProvider` maneja Home/Búsqueda/Detalle de artista/Detalle de álbum/Géneros, cada sección con su propio `ViewState`. `FavoritesProvider` guarda favoritos en memoria. `PlayerProvider` controla la reproducción con `audioplayers`.
- **presentation/screens** y **presentation/widgets** — la UI.
- **core** — constantes, tema y rutas: nada de lógica de negocio, solo configuración compartida.

## API de Deezer

No requiere autenticación para lectura del catálogo (búsqueda, charts, artistas, álbumes, tracks, géneros) — solo hace falta OAuth para acciones de usuario, que esta app no usa.

| Endpoint | Uso en la app |
|---|---|
| `GET /chart` | Home: tracks/artistas/álbumes populares |
| `GET /chart/{genreId}` | Detalle de género: mismo formato, filtrado |
| `GET /genre` | Lista de géneros para "Explorar" |
| `GET /search?q=` | Búsqueda de canciones |
| `GET /search/artist?q=` | Búsqueda de artistas |
| `GET /artist/{id}` | Detalle de artista |
| `GET /artist/{id}/top` | Top canciones del artista |
| `GET /artist/{id}/albums` | Álbumes del artista |
| `GET /album/{id}` | Detalle de álbum |
| `GET /album/{id}/tracks` | Canciones del álbum |

Cada track trae un campo `preview`: un mp3 de 30s público, que es lo que reproduce el `PlayerProvider` — el reproductor suena de verdad, no es solo una maqueta visual.

Todas las peticiones pasan por `MusicApiService._getJson()`, que centraliza: armar la URL con `ApiConstants.baseUrl`, validar el status code, y detectar el formato de error propio de Deezer (`{"error": {...}}`) para convertirlo en una `Exception` legible.

## Manejo de estados

Cada sección de `MusicProvider` expone un `ViewState`:

```dart
enum ViewState { initial, loading, success, error, empty }
```

Es el mismo patrón `_isLoading` / `_errorMessage` del código base del profe, pero expresado como una máquina de estados explícita en vez de dos flags sueltos. Cada pantalla renderiza `LoadingView` / `ErrorView` (con botón reintentar) / `EmptyView` / contenido según corresponda (`presentation/widgets/state_views.dart`).

## Pantallas

1. **Home** — saludo, acceso a búsqueda, "Recomendado para ti", "Artistas populares", "Álbumes destacados" (todo desde `/chart`), más "Escuchado recientemente" alimentado por el historial del `PlayerProvider`.
2. **Buscar** — búsqueda en vivo (debounce de 500ms) contra `/search` y `/search/artist`, más una sección "Explorar por género" (`/genre`).
3. **Detalle de género** — artistas, álbumes y canciones de un género (`/chart/{genreId}`).
4. **Detalle de artista** — foto, fans, botón reproducir, top canciones, álbumes.
5. **Detalle de álbum** — portada, botón reproducir, tracklist numerado.
6. **Reproductor** — reproduce el preview de 30s, con progreso, play/pause/siguiente/anterior, shuffle, repeat y favorito; el nombre del artista es clickeable y navega a su perfil.
7. **Favoritos** — canciones marcadas con ♡, guardadas en memoria durante la sesión.

Navegación con `Navigator` + rutas nombradas (`core/routes/app_routes.dart`), transiciones custom (fade+zoom para artista/álbum/género, slide-up para el reproductor) y un mini-player persistente sobre la barra inferior.

## Cómo correr el proyecto

```bash
flutter pub get
flutter run -d windows   # o -d chrome, o un dispositivo/emulador Android
```

## CORS en Flutter Web (importante)

Deezer **no** manda la cabecera `Access-Control-Allow-Origin`, así que el navegador bloquea las peticiones si se corre en Chrome/Edge directo. En Android, Windows, iOS, macOS y Linux no aplica (no son peticiones de navegador).

Para poder probar en Web igual, hay un proxy local de solo desarrollo en `tool/cors_proxy.dart` que reenvía a Deezer agregando esa cabecera. `ApiConstants.baseUrl` lo usa automáticamente cuando `kIsWeb` es `true`.

```bash
# En una terminal, antes de correr en Chrome:
dart run tool/cors_proxy.dart

# En otra terminal:
flutter run -d chrome
```

## Despliegue

### Android (compartir con compañeros)

No hay problema de CORS: es una app nativa, no un navegador, así que llama a Deezer directo sin proxy.

```bash
flutter build apk --release
```

Genera `build/app/outputs/flutter-apk/app-release.apk`. Se comparte el archivo (Drive, WhatsApp, etc.); quien lo instale debe activar "instalar apps de orígenes desconocidos".

### Web (Vercel + GitHub Actions)

🔗 **Producción:** https://web-topaz-nine-40.vercel.app

`tool/cors_proxy.dart` es **solo para desarrollo local** — corre en `localhost:8787` de tu propia máquina, así que una vez publicada la app, nadie más tiene ese proxy disponible. Para producción, el mismo proxy vive como función serverless dentro del proyecto de Vercel, servida desde el mismo origen que la app — no hace falta CORS real porque es same-origin.

Estructura de despliegue:
```
deploy/web/
├── vercel.json               → reescribe /api/deezer/:path* → /api/proxy?path=:path*
├── api/proxy.js              → función serverless: reenvía a Deezer (equivalente prod de tool/cors_proxy.dart)
├── public/                    → build de Flutter Web compilado (generado, no se versiona)
└── build_and_deploy.sh        → compila con las flags correctas y copia a public/
```

`ApiConstants._webProxyBaseUrl` usa `String.fromEnvironment('DEEZER_PROXY_BASE_URL', defaultValue: 'http://localhost:8787')`, así que sin tocar nada `flutter run -d chrome` sigue funcionando exactamente igual que antes. Solo el build de producción cambia ese valor a `/api/deezer` vía `--dart-define`.

**Despliegue automático (recomendado):** cada `git push` a `main` que toque `lib/`, `web/`, `pubspec.yaml` o `deploy/web/api/` dispara `.github/workflows/deploy-web.yml`, que instala Flutter, compila (con `--wasm`, ver más abajo por qué) y despliega solo. No hay que hacer nada manual — con hacer commit y push basta. Requiere 3 secrets ya configurados en el repo de GitHub (`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`).

**Despliegue manual** (para probar algo antes de commitear, o si el Action falla):
```bash
# 1. Compila apuntando al proxy serverless y copia el resultado a deploy/web/public
bash deploy/web/build_and_deploy.sh

# 2. Login (una sola vez; abre el navegador para autenticarte)
cd deploy/web
vercel login

# 3. Deploy a producción
vercel --prod
```

⚠️ Si haces un deploy manual y **luego** haces `git push`, el Action de GitHub va a volver a desplegar por su cuenta segundos después — si tu cambio manual no estaba comiteado todavía, el Action lo va a pisar con la versión vieja. Comitea primero, despliega manual después (o simplemente deja que el Action lo haga solo).

## Problemas del despliegue web y cómo se resolvieron

Llevar la app de "corre en mi máquina" a "funciona en producción para cualquiera" no salió a la primera. Se documentan acá los problemas reales que aparecieron, en el orden en que se encontraron, porque varios no son obvios y podrían repetirse si se toca esta parte del proyecto.

**Lección general que atraviesa casi todo esto: `curl` no detecta bugs de la app compilada.** Varias veces un `curl` a la API de producción respondía perfecto mientras la app real, corriendo en un navegador de verdad, estaba rota — porque el problema no estaba en el servidor sino en cómo el *build* de Flutter terminaba armando las URLs, o en cómo el navegador renderizaba. La verificación real solo llegó abriendo el sitio en Chrome (con la extensión Claude in Chrome) y reproduciendo el flujo a mano.

1. **El proxy devolvía 404 en rutas de más de un segmento.** `/api/deezer/chart` funcionaba pero `/api/deezer/album/123/tracks` o `/api/deezer/search/artist` no — Vercel nunca llegaba a invocar la función. La convención de archivos con corchetes (`api/deezer/[...path].js`) para rutas "catch-all" resultó no comportarse como en un proyecto Next.js cuando Vercel no detecta ningún framework. Se reemplazó por un `vercel.json` con un `rewrite` explícito hacia un archivo plano (`api/proxy.js`), sin depender de esa convención.

2. **El sitio pedía login de Vercel para cualquiera que lo abriera.** Vercel tenía activada la protección SSO/Deployment Protection a nivel de proyecto, así que cualquier URL `.vercel.app` (incluida la de producción) redirigía a una pantalla de login de Vercel. Se desactivó con `vercel project protection disable web --sso`.

3. **Un `git push` disparó un despliegue vacío que rompió el sitio.** Mientras el repo de GitHub estaba conectado de forma nativa a Vercel, un push activó un build automático de Vercel — que no tiene Flutter instalado, así que sirvió un sitio sin `index.html`, reemplazando el deploy bueno. Se desconectó esa integración nativa (`vercel git disconnect`) y se reemplazó por un GitHub Action propio (`.github/workflows/deploy-web.yml`) que sí instala Flutter antes de compilar.

4. **Git Bash rompía la URL del proxy en cada build, en silencio.** El comando `flutter build web --dart-define=DEEZER_PROXY_BASE_URL=/api/deezer`, corrido desde Git Bash en Windows, hacía que MSYS convirtiera automáticamente `/api/deezer` (por empezar con `/`) en una ruta de Windows tipo `C:/Program Files/Git/api/deezer` **antes** de pasárselo a Flutter. El build terminaba "exitoso" pero con esa URL rota horneada adentro — el navegador terminaba pidiendo `file:///C:/Program Files/Git/api/deezer/chart`. Este fue el más difícil de encontrar porque un `curl` a mano a la URL correcta nunca lo iba a reproducir. Se arregló anteponiendo `MSYS_NO_PATHCONV=1` al comando en `build_and_deploy.sh`.

5. **El service worker de Flutter interceptaba las llamadas a la API y a veces las rompía.** Al mover el proxy al mismo origen que la app (para el punto 1), sin querer se lo puso dentro del scope del service worker que Flutter genera automáticamente — causando fallos 503 intermitentes sin patrón claro. Como esta app no necesita soporte offline/PWA, se desregistra el service worker activamente desde `web/index.html` apenas carga la página.

6. **Las imágenes dejaban de cargar al volver de una pantalla de detalle (el más largo de depurar).** Entrar a un álbum o artista y volver (con el botón del navegador, la flecha de la pantalla, o el botón "atrás" del sistema — daba igual cuál) dejaba algunas o todas las imágenes del Home en negro, con la consola llena de `WebGL: INVALID_VALUE: texImage2D: no image`. Se probaron y descartaron varias hipótesis en orden — la animación `Hero` (se quitó, no era eso), falta de `key`s estables en las listas (se agregaron, ayudan mas no era la causa raíz), y decodificar las imágenes a resolución nativa en vez del tamaño real de pantalla (se agregó `memCacheWidth`/`memCacheHeight`, buena práctica pero tampoco era la causa). La causa real: un bug del renderer CanvasKit en el compilador JS por defecto de Flutter Web, relacionado con el patrón de shell con `Navigator` anidado que mantiene la pantalla de atrás montada (no destruida) debajo de la nueva. Compilar con `--wasm` (un pipeline de renderizado distinto) lo resolvió — **pero solo en Chrome**; en Safari/iOS el mismo síntoma seguía apareciendo. La solución final, que si funciona en cualquier navegador: un `RouteObserver` registrado en el `Navigator` de `AppShell`, que `HomeScreen` escucha vía `RouteAware.didPopNext()` para incrementar un contador que se mete en las `key` de sus tarjetas — así Flutter las reconstruye desde cero cada vez que se vuelve a Home, en vez de reusar el estado (y la textura) vieja.

7. **El mini-player abría un reproductor por cada toque si se tocaba varias veces seguidas.** `onTap` llamaba `Navigator.pushNamed` sin ningún control, así que tocarlo 3 veces apilaba 3 pantallas de reproductor una encima de otra. Se agregó un flag (`_opening`) que ignora toques mientras la transición de apertura está en curso.

8. **El disco se quedó sin espacio instalando el SDK de Android.** Al intentar generar el `.apk` para compartir con compañeros, hubo que instalar el Android SDK (command-line tools) desde cero, lo que llenó por completo el disco `C:` (2.6GB libres de 238GB) a mitad de la descarga del NDK. Se revirtió esa instalación a pedido del usuario; **el build de APK y de Windows quedaron pendientes** de que se libere espacio en disco — ver [Android (compartir con compañeros)](#android-compartir-con-compañeros).

## Estructura de carpetas y clases

```
lib/
├── main.dart                          → VibraApp: arma el MultiProvider (Music/Favorites/Player)
│                                          y el MaterialApp raíz. Único punto de entrada.
│
├── core/                               (config y constantes — capa transversal)
│   ├── constants/
│   │   └── api_constants.dart          → ApiConstants: baseUrl (Deezer directo o proxy si kIsWeb)
│   ├── theme/
│   │   └── app_theme.dart              → AppColors + AppTheme: paleta oscura y ThemeData únicos
│   └── routes/
│       └── app_routes.dart             → AppRoutes: nombres de ruta + transiciones (fade-scale, slide-up)
│
├── data/                                (capa de datos)
│   ├── models/                          → 1:1 con el JSON de Deezer, sin lógica de UI
│   │   ├── artist.dart                  → Artist (id, name, pictureMedium/Big, nbAlbum, nbFan)
│   │   ├── album.dart                   → Album (id, title, coverMedium/Big, artistName, nbTracks...)
│   │   ├── track.dart                   → Track (id, title, duration, preview, datos de artista/álbum embebidos)
│   │   └── genre.dart                   → Genre (id, name)
│   ├── services/
│   │   └── music_api_service.dart       → MusicApiService: único lugar con http.get() real,
│   │                                       decodifica JSON y traduce errores de Deezer a Exception
│   └── repositories/
│       └── music_repository.dart        → MusicRepository + HomeFeed: punto único de acceso a datos
│                                           para la UI; combina/transforma lo que devuelve el service
│
├── providers/                           (capa de lógica/estado — ChangeNotifier + provider)
│   ├── view_state.dart                  → enum ViewState (initial/loading/success/error/empty)
│   ├── music_provider.dart              → MusicProvider: estado de Home, Búsqueda, Detalle de
│   │                                       artista/álbum/género — cada sección con su propio ViewState
│   ├── favorites_provider.dart          → FavoritesProvider: favoritos en memoria (Map<id, Track>)
│   └── player_provider.dart             → PlayerProvider: reproducción (audioplayers), cola,
│                                           shuffle/repeat, historial de "escuchado recientemente"
│
└── presentation/                        (capa de presentación — solo UI)
    ├── screens/
    │   ├── app_shell.dart                → AppShell: shell persistente (Navigator anidado +
    │   │                                     barra inferior + mini-player), nunca se desmonta
    │   ├── home_screen.dart               → HomeScreen: carruseles de recomendados/populares
    │   ├── search_screen.dart             → SearchScreen: búsqueda con debounce + explorar géneros
    │   ├── genre_screen.dart              → GenreScreen: detalle de un género
    │   ├── artist_screen.dart             → ArtistScreen: detalle de artista
    │   ├── album_screen.dart              → AlbumScreen: detalle de álbum
    │   ├── player_screen.dart             → PlayerScreen: reproductor a pantalla completa
    │   └── favorites_screen.dart          → FavoritesScreen: lista de favoritos
    └── widgets/
        ├── state_views.dart               → LoadingView / ErrorView / EmptyView (reutilizados
        │                                     en todas las pantallas en vez de ifs repetidos)
        ├── track_tile.dart                 → TrackTile: fila de canción (play + favorito)
        ├── artist_card.dart                → ArtistCard: tarjeta circular de artista
        ├── album_card.dart                 → AlbumCard: tarjeta de álbum
        ├── genre_card.dart                  → GenreCard: tarjeta de color sólido por género
        ├── mini_player.dart                 → MiniPlayer: barra persistente sobre la nav inferior
        │                                       (con guard anti-doble-toque, ver sección de problemas)
        ├── favorite_button.dart             → FavoriteButton: ícono de corazón reutilizable
        ├── gradient_header.dart             → GradientHeader: fondo degradado tipo Spotify
        ├── fade_slide_in.dart               → FadeSlideIn: animación de entrada fade + slide-up
        └── pressable_scale.dart             → PressableScale: feedback táctil (escala al presionar)
                                                para tarjetas y botones

tool/
└── cors_proxy.dart                     → proxy CORS solo para desarrollo en Web (ver sección de arriba)

deploy/web/                             → despliegue a producción (Vercel), ver sección Despliegue
.github/workflows/deploy-web.yml        → CI: build + deploy automático en cada push relevante
```

Librerías de animación (`flutter_animate`, `shimmer`) y de UI (`lucide_icons_flutter`, `cached_network_image`) están en `pubspec.yaml` con un comentario explicando para qué se usa cada una.
