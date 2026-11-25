# Changelog

Todos los cambios destacables de Coverfy (iOS) se documentan en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el versionado es [SemVer](https://semver.org/lang/es/).

## [Unreleased]

## [0.4.4] - 2026-11-25

### Changed
- El workflow de release explica por qué no puede asignar una build a un grupo de TestFlight.

### Changed
- Las releases de GitHub llevan como notas la sección del changelog de cada versión.

## [0.4.3] - 2026-11-25

### Changed
- El workflow de release acepta la clave `.p8` de App Store Connect tanto en texto como en base64.
- El workflow de release comprueba que el certificado y el perfil coinciden y muestra los errores de firma y exportación.

## [0.4.0] - 2026-11-25

### Added
- El escaneo del ticket rellena también el nombre del producto (la línea de artículo más cara antes del total), listo para buscar su imagen. Se puede editar.

## [0.3.0] - 2026-11-25

### Added
- Búsqueda de imagen del producto: "Buscar imagen del producto" busca el nombre en SerpAPI (Google Imágenes) y te deja elegir una imagen sin hacer la foto.

## [0.1.1] - 2026-11-25

### Added
- Foto del producto: captura opcional con la cámara en el alta, mostrada como miniatura en la lista y como cabecera en el detalle.
- Al compartir la reclamación se adjunta la foto del ticket junto al texto.
### Changed
- Pantalla de detalle rediseñada: barra superior de color, tarjeta de estado con días restantes y barra de progreso, tarjeta de datos con iconos.
### Fixed
- Las fotos se resuelven por nombre dentro de Documents, para que no se pierdan cuando cambia la ruta del sandbox tras una actualización.

## [0.0.2] - 2026-11-24

### Added
- Onboarding en el primer arranque: tres pantallas que explican el escaneo de tickets, los avisos de caducidad y las reclamaciones, con opción de saltarlo.
### Changed
- Paleta de colores de marca (azul/turquesa/naranja) y filas de la lista coloreadas según estado (naranja si caduca en <=30 días, rojo si caducada).

## [0.0.1] - 2026-11-19

### Added
- Escaneo de tickets con la cámara y OCR on-device (Vision): detecta fecha de compra y tienda automáticamente.
- Registro local de garantías (SwiftData): producto, tienda, fecha, meses de garantía (24 por defecto), notas y foto del ticket.
- Listado de garantías ordenado por caducidad, con contador de días restantes y marcado de caducadas/próximas a caducar.
- Aviso automático de caducidad: notificaciones locales programadas 30 y 7 días antes de que expire cada garantía.
- Generador de reclamación conforme a la garantía legal (RD-ley 7/2021): escrito listo para compartir por email o mensajería.
- Eliminación de garantías con confirmación.

[Unreleased]: https://github.com/ralvarezmar/coverfyIOS/compare/0.0.1...HEAD
[0.0.1]: https://github.com/ralvarezmar/coverfyIOS/releases/tag/0.0.1
