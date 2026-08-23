# Product Requirements Document

Producto: DentiCore Connect
Release: 0.1
Estado: Release Candidate

## 1. Objetivo

Proveer a pacientes de una clínica dental una aplicación iOS segura para descubrir servicios, programar citas, consultar su agenda, cancelar citas permitidas y recibir recordatorios, reutilizando y fortaleciendo el backend Spring Boot heredado.

## 2. Resultado esperado

El incremento debe demostrar un producto cliente-servidor desplegado y un recorrido funcional de extremo a extremo. La aplicación no sustituye el diagnóstico odontológico, no prescribe tratamientos y no expone historias clínicas completas.

## 3. Requisitos funcionales

| ID | Requisito | Prioridad | Estado |
|---|---|---:|---|
| RF-01 | Autenticar paciente con DNI y contraseña | P0 | Implementado |
| RF-02 | Conservar JWT únicamente en Keychain | P0 | Implementado |
| RF-03 | Recuperar perfil y contexto de clínica | P0 | Implementado |
| RF-04 | Listar especialidades y servicios activos | P0 | Implementado |
| RF-05 | Listar odontólogos por especialidad | P0 | Implementado |
| RF-06 | Consultar horarios disponibles por fecha | P0 | Implementado |
| RF-07 | Programar una cita propia | P0 | Implementado |
| RF-08 | Listar citas propias y conservar caché local | P0 | Implementado |
| RF-09 | Consultar detalle de una cita propia | P0 | Implementado |
| RF-10 | Cancelar citas propias permitidas | P0 | Implementado |
| RF-11 | Programar/eliminar recordatorios locales | P1 | Implementado |
| RF-12 | Navegar mediante tabs Inicio, Citas y Perfil | P1 | Implementado |
| RF-13 | Mostrar perfil de solo lectura | P1 | Implementado |
| RF-14 | Ocultar DNI por defecto y revelarlo a voluntad | P1 | Implementado |
| RF-15 | Cerrar sesión y limpiar credenciales locales | P0 | Implementado |

## 4. Criterios de aceptación principales

### Autenticación

- Credenciales válidas devuelven JWT, tipo, expiración, rol y clínica.
- Credenciales inválidas devuelven `401` sin revelar si el DNI existe.
- Un `401` en una ruta protegida finaliza la sesión local.
- El rol distinto de `PACIENTE` no accede al flujo móvil.

### Agenda

- El paciente solo consulta o modifica citas propias y de su clínica.
- La fecha de creación debe ser futura.
- El horario debe provenir de disponibilidad calculada.
- Dos citas activas no pueden solaparse para un odontólogo.
- Solo `PENDIENTE` y `CONFIRMADA` pueden cancelarse por el paciente.
- La cancelación conserva trazabilidad y no elimina físicamente el registro.

### Experiencia iOS

- Todas las pantallas principales están declaradas en `Main.storyboard`.
- Los controladores emplean `@IBOutlet`, `@IBAction`, `UITableView` y segues donde corresponde.
- La interfaz presenta carga, vacío, error recuperable y modo offline.
- Las actualizaciones de UIKit ocurren en el hilo principal.
- El contenido soporta Dynamic Type y VoiceOver en las acciones esenciales.

## 5. Requisitos no funcionales

| ID | Requisito |
|---|---|
| RNF-01 | Contraseñas protegidas con BCrypt y JWT firmado mediante secreto de entorno. |
| RNF-02 | Autorización por rol, clínica y propiedad del recurso. |
| RNF-03 | Token iOS almacenado en Keychain; ningún token en UserDefaults o Core Data. |
| RNF-04 | PostgreSQL evoluciona exclusivamente mediante Flyway. |
| RNF-05 | Exclusión de solapamientos aplicada también en base de datos. |
| RNF-06 | Fechas intercambiadas como ISO 8601 con offset y zona de clínica `America/Lima`. |
| RNF-07 | Errores REST usan un sobre uniforme sin stack trace al cliente. |
| RNF-08 | El listado de citas puede mostrarse desde Core Data cuando falla la red. |
| RNF-09 | El backend debe superar CI antes de integrarse en ramas protegidas. |
| RNF-10 | El servicio ofrece health check sin exponer detalles internos. |

## 6. Dependencias

- iOS 17.6 o superior.
- Xcode 26.3 o compatible.
- API Spring Boot disponible por HTTPS.
- PostgreSQL 16.
- Permiso de notificaciones para recordatorios locales.

## 7. Fuera de alcance

Edición de datos, fotografía de perfil, Cloudinary, pagos, reprogramación, historial clínico móvil, odontograma móvil, teleodontología, diagnóstico, Watson Assistant, Android, App Store y administración SaaS multitenant.

## 8. Métricas iniciales del piloto

- Porcentaje de recorridos de reserva completados.
- Conflictos de agenda rechazados correctamente.
- Citas consultadas desde caché durante una falla de red.
- Recordatorios programados para citas activas.
- Errores `5xx` observados durante la demostración.
- Tiempo de reactivación del servicio Render en arranque en frío.
