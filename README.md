# Coverfy (iOS)

Escanea el ticket al comprar, guarda la garantía, recibe un aviso antes de que caduque y genera la reclamación si el producto se rompe.

## Funcionalidad (MVP)

- **Escaneo de tickets** con la cámara (OCR on-device con Vision): detecta fecha de compra y tienda automáticamente.
- **Registro de garantías** con SwiftData: producto, tienda, fecha, meses de garantía (por defecto 24), notas y foto del ticket.
- **Aviso de caducidad**: notificaciones locales programadas 30 y 7 días antes de que caduque la garantía.
- **Reclamación lista para enviar**: genera un escrito de reclamación conforme a la garantía legal (RD-ley 7/2021, España) y lo comparte con ShareLink.

## Stack

- SwiftUI + SwiftData (iOS 17+)
- Vision (VNRecognizeTextRequest), UserNotifications
- Sin dependencias externas

## Build

Abrir `Coverfy.xcodeproj` en Xcode 15.2+ y ejecutar en un dispositivo/simulador iOS 17+.

## Estructura

```
Coverfy/
├── Models/          # SwiftData: Warranty
├── OCR/             # ReceiptScanner (Vision) + ReceiptParser (heurísticas)
├── Notifications/   # ExpiryNotifier (avisos 30/7 días antes)
├── Claim/           # ClaimGenerator (escrito de reclamación)
└── Views/           # Lista, alta (escaneo/formulario) y detalle
```
