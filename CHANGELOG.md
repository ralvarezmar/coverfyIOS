# Changelog

Todos los cambios destacables de Coverfy (iOS) se documentan en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el versionado es [SemVer](https://semver.org/lang/es/).

## [Unreleased]

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
