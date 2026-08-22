# DentiCore Connect iOS

Base UIKit del primer flujo vertical: inicio de sesión de paciente contra el backend Spring Boot.

## Primera integración en Xcode

1. En macOS, cambia a la rama feature/ios-login-foundation y actualiza el repositorio.
2. En Xcode crea un proyecto iOS de tipo App:
   - Product Name: DentiCoreConnect
   - Interface: Storyboard
   - Language: Swift
   - Deployment Target: iOS 16.2
   - Include Tests: activado
   - Use Core Data: activado
3. Guarda el proyecto dentro de la carpeta ios.
4. Añade la carpeta DentiCoreConnect/Sources al target principal usando Create groups.
5. Añade DentiCoreConnect/Tests/LoginResponseTests.swift solamente al target de pruebas.
6. En Info.plist agrega API_BASE_URL como String. Para una prueba local usa http://localhost:8080; para integración real usa la URL HTTPS desplegada.
7. Para desarrollo local por HTTP agrega NSAppTransportSecurity > NSAllowsLocalNetworking = YES. No habilites tráfico HTTP global.

## Storyboard de Login

Crea un LoginViewController embebido en Navigation Controller. En la vista usa un UIStackView vertical para reducir restricciones y agrega:

- UITextField para DNI
- UITextField para contraseña
- UIButton para ingresar
- UIActivityIndicatorView
- UILabel para errores

Asigna LoginViewController como Custom Class en Identity Inspector y verifica Inherit Module From Target.

Con Connections Inspector vincula:

| Elemento | Conexión |
|---|---|
| DNI | dniTextField |
| Contraseña | passwordTextField |
| Botón | loginButton |
| Indicador | activityIndicator |
| Etiqueta de error | errorLabel |
| Touch Up Inside del botón | loginButtonTapped: |

Crea desde LoginViewController un segue hacia la pantalla principal con el identificador showMain.

## Resultado esperado del primer corte

- DNI y contraseña se validan.
- POST /auth/login se consume con URLSession.
- Se acepta tanto la respuesta heredada token/rol como el contrato objetivo accessToken/rol/contextoClinica.
- El JWT se guarda en Keychain.
- Errores de red, 401, 403 y decodificación se muestran sin bloquear la interfaz.
- Todas las actualizaciones visuales regresan al hilo principal.

El siguiente incremento será adaptar el backend para devolver el contrato objetivo y agregar los endpoints de paciente.
