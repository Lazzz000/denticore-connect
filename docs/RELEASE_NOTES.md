# Release Notes — 0.1.0-rc.1

Fecha de corte: 23 de agosto de 2026

## Resumen

Primera versión candidata de DentiCore Connect orientada al paciente. Integra la aplicación iOS UIKit/Storyboard con la API móvil Spring Boot y PostgreSQL desplegados en Render.

## Nuevo

- Flujo de login con JWT y contexto de clínica.
- Sesión segura en Keychain.
- Tab bar con Inicio, Citas y Perfil.
- Dashboard con saludo, próxima cita y accesos rápidos.
- Catálogo de especialidades y servicios.
- Selección de odontólogo y disponibilidad.
- Creación de citas con fecha y offset.
- Listado de citas con caché Core Data.
- Detalle y cancelación auditada.
- Recordatorios locales sincronizados con citas activas.
- Perfil de paciente de solo lectura.
- DNI oculto por defecto con acción mostrar/ocultar.
- Identidad demo autorizada y configurable desde Render (`Carlos Miguel Lazo Dominguez`).
- Clínica visible como `Clínica Dental Dr. Dave Cáceres`.
- Sede principal visible como `Sede San Juan de Lurigancho`.
- Tres citas históricas atendidas, idempotentes y no cancelables.
- Cita próxima regenerable para demostrar un recordatorio local en el simulador.
- Marca gráfica e icono de aplicación incorporados al catálogo de assets.
- Sistema visual centralizado en `DentiCoreTheme`.
- Fachada `/pacientes/me` con autorización por rol y propiedad.
- Modelo de clínica, sede, horarios y eventos de cita.
- Protección de solapamiento a nivel PostgreSQL.
- Flyway, Docker, Render y CI backend.
- Contrato OpenAPI y documentación técnica actualizados.

## Corregido

- Nombres reales de odontólogo y sede en citas.
- Contratos de detalle y cancelación.
- Concurrencia de UI y compatibilidad con Swift 6.
- Restricciones y prototipos de tablas en Storyboard.
- Navegación y expiración de sesión centralizadas.

## Limitaciones conocidas

- Render gratuito puede presentar arranque en frío.
- La compilación iOS debe verificarse en macOS/Xcode.
- Los recordatorios son locales, no push.
- No existe reprogramación desde iOS.
- Perfil, correo y fotografía no son editables.
- El piloto usa una clínica; no hay administración SaaS multitenant.
- El back-office Angular y módulos clínicos/ventas son activos heredados.

## Pendiente para declarar 0.1.0

- Build y pruebas en Xcode de esta candidata.
- Ejecución documentada de casos críticos.
- Confirmación de cero advertencias de Auto Layout.
- Revisión final de datos demo y secretos.
- Manual de usuario/instalación y evidencia de integración para sustentación.
