# DentiCore Connect iOS

Cliente móvil del paciente construido con Swift, UIKit, `Main.storyboard`, Core Data y XCTest.

## Requisitos

- Xcode 26.3 o compatible.
- iOS 17.6 o superior.
- Simulador iPhone.

## Apertura

Abrir:

```text
DentiCoreConnect/DentiCoreConnect.xcodeproj
```

La URL del servicio se obtiene de `API_BASE_URL` en `Info.plist`. La configuración incluida consume la API de Render.

## Funciones

- Login y sesión Keychain.
- Tab bar Inicio/Citas/Perfil.
- Catálogo, odontólogos y disponibilidad.
- Reserva, listado offline, detalle y cancelación.
- Recordatorios locales.
- Perfil de solo lectura y DNI protegido.
- Tema visual centralizado.

## Verificación

- `⌘B`: compilar.
- `⌘U`: ejecutar XCTest/XCUITest.
- Validar el recorrido descrito en `../docs/TEST_PLAN.md`.

El símbolo `mouth.fill` es un fallback. Al añadir un recurso válido a `BrandLogo.imageset`, el logo se presenta automáticamente en Login e Inicio.
