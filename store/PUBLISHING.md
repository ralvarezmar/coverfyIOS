# Publicación automática — Coverfy (iOS)

Esquema replicado de `veganIOS`: GitHub Actions en `macos-*` compila, firma y sube a TestFlight/App Store en cada push a `main`.

## Flujo

1. **Push a `development`** → `ci.yml`: compila el scheme en simulador (`xcodebuild build-for-testing` / tests).
2. **Push a `main`** → `release.yml` / `release-ios.yml`:
   - Tag SemVer automático.
   - Stamp de versión en `CHANGELOG.md`.
   - Selecciona el Xcode del runner (`sudo xcode-select`), crea keychain temporal, importa el `.p12`, instala provisioning profiles.
   - `xcodebuild archive` + `-exportArchive` (método `app-store`).
   - Sube a TestFlight vía App Store Connect API (`xcrun altool`/`notarytool` o fastlane `pilot`).
   - Crea la release de GitHub con las notas.
3. **Manual** → `appstore-submit.yml` (workflow_dispatch): promueve el build de TestFlight a revisión de App Store y fija el texto "What to Test" / release notes del changelog.

## Secretos necesarios en el repo (Settings → Secrets and variables → Actions)

| Secreto | Cómo obtenerlo |
|---|---|
| `ASC_API_KEY_P8` | Key `.p8` de App Store Connect → Users and Access → Integrations (ver guía de regeneración abajo) |
| `ASC_KEY_ID` | Key ID asociado a esa `.p8` |
| `ASC_ISSUER_ID` | Issuer ID de la misma página |
| `ASC_TEAM_ID` | Team ID de developer.apple.com → Membership |
| `IOS_DIST_CERT_P12` | Certificado "Apple Distribution" exportado de Keychain en `.p12` y pasado a base64 |
| `IOS_DIST_CERT_PASSWORD` | Contraseña elegida al exportar el `.p12` |
| `IOS_APP_PROFILE` | Provisioning profile App Store de `com.ramivisuals.coverfy` (`.mobileprovision` en base64) |
| `IOS_WIDGET_PROFILE` | Solo si se añade widget — puede omitirse al inicio |

### Regenerar las claves si no las tienes

- **ASC_***: App Store Connect → Users and Access → Integrations → App Store Connect API → crear key nueva → descargar `.p8` (solo descargable una vez) y anotar Key ID + Issuer ID. Team ID en developer.apple.com → Membership details.
- **Certificado**: developer.apple.com → Certificates → crear "Apple Distribution" (o exportar el existente de Keychain → My Certificates → Export `.p12`).
- **Perfil**: developer.apple.com → Profiles → "+" → App Store → App ID `com.ramivisuals.coverfy` → certificado anterior → descargar `.mobileprovision`.
- Base64: `base64 -i archivo.p12` / `base64 -i perfil.mobileprovision`.

## Qué hace falta implementar en el repo

- [ ] `.github/workflows/ci.yml` — build en `macos-26` con Xcode estable.
- [ ] `.github/workflows/release-ios.yml` — tag, keychain temporal, archive, export, upload TestFlight.
- [ ] `.github/workflows/appstore-submit.yml` — submit a revisión + "What to Test".
- [ ] `ExportOptions.plist` (método `app-store`, `uploadSymbols: true`).
- [ ] `DEVELOPMENT_TEAM` = `ASC_TEAM_ID` y `CODE_SIGN_STYLE = Manual` en release.
- [ ] Primer build manual a TestFlight para que exista la app en App Store Connect (o crear el record antes en la web).

## Orden de puesta en marcha

1. Crear el App ID `com.ramivisuals.coverfy` en developer.apple.com → Identifiers.
2. Crear la app en App Store Connect con ese bundle id.
3. Configurar los 7 secretos en el repo.
4. Commitear workflows + ExportOptions.
5. `git push` a `main` → build en TestFlight.
