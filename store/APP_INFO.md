# Coverfy — Ficha técnica para App Store

| Campo | Valor |
|---|---|
| **Bundle ID** | `com.ramivisuals.coverfy` (pendiente confirmar si también pasamos a `com.ramivisuals.coverfy` para unificar con Android) |
| **Nombre visible** | Coverfy |
| **Versión inicial** | 0.0.1 (build 1) |
| **Deployment target** | iOS 17.0 |
| **Categoría sugerida** | Utilidades / Productividad |
| **Clasificación de edad** | 4+ (sin compras, sin anuncios) |
| **Permisos (Info.plist)** | NSCameraUsageDescription |

## Assets en esta carpeta

| Archivo | Uso en App Store Connect |
|---|---|
| `app_icon_1024.png` | Icono de la app (1024x1024, sin canal alfa) |
| `screenshots_iphone_6_5/*.png` | Capturas iPhone 6.5" (1284x2778, mín. 1, máx. 10) |
| `STORE_DESCRIPTION.md` | Textos ES/EN (la "descripción corta" es el subtítulo de App Store, máx. 30 car.) |

## Checklist pendiente en App Store Connect

- [ ] Crear el App ID / bundle id en developer.apple.com → Identifiers.
- [ ] Crear la app en App Store Connect con ese bundle id.
- [ ] Subir descripción, palabras clave y capturas.
- [ ] Rellenar "Información de privacidad de la app": la app no recoge datos (todo local) → "No data collected" en la mayoría de categorías; fotos procesadas on-device.
- [ ] URL de política de privacidad (aunque no recoja datos, Apple la exige en la ficha).
- [ ] Firmar con certificado Apple Distribution y provisioning profile App Store (ver secretos del repo: ASC_*, IOS_*).
- [ ] Subir el primer build vía Xcode/fastlane y enviar a TestFlight.

## Nota sobre capturas

Son maquetas ilustrativas generadas para la ficha. Sustituir por capturas reales del simulador/dispositivo cuando el build funcione (Cmd+S en el simulador, iPhone 15 Pro Max para el tamaño 6.5"/6.7").
