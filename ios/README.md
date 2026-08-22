# DentiCore Connect iOS

Proyecto UIKit con Storyboard, XCTest y Core Data para el cliente móvil del paciente.

## Abrir

Abre `DentiCoreConnect/DentiCoreConnect.xcodeproj` con Xcode 26.3 o compatible.

## Configuración actual

- Target: iPhone
- Deployment target: iOS 17.6
- Bundle ID: `com.denticore.DentiCoreConnect`
- API: clave `API_BASE_URL` de `Info.plist`
- Seguridad de sesión: Keychain

La URL local configurada es `http://localhost:8080/api/v1`. Se sustituirá por HTTPS al finalizar el despliegue del backend.

## Estado

La base de red, autenticación, modelos de login, sesión y pruebas de decodificación ya forma parte del target mediante los grupos sincronizados del proyecto.
