# Plan de pruebas

## 1. Objetivo

Verificar el recorrido principal del paciente, la seguridad de recursos propios, la integridad de agenda y la estabilidad del cliente iOS antes de etiquetar el Release 0.1.

## 2. Niveles

| Nivel | Alcance | Herramientas |
|---|---|---|
| Unitario iOS | Decodificación, presentación, reglas locales | XCTest |
| Unitario backend | Servicios y validaciones | JUnit, Mockito |
| Integración backend | JPA, Flyway, seguridad y agenda | Spring Boot Test, PostgreSQL |
| Contrato API | Métodos, códigos y esquemas | OpenAPI, Postman/Rest Assured |
| UI iOS | Login y navegación esencial | XCUITest/manual |
| Integración E2E | iOS → Render → PostgreSQL | Simulador + API desplegada |

## 3. Casos críticos

| ID | Escenario | Resultado esperado |
|---|---|---|
| CP-01 | Login válido de paciente | 200, sesión y tabs visibles |
| CP-02 | Credenciales inválidas | 401, mensaje neutro |
| CP-03 | Token vencido | Sesión local eliminada y login |
| CP-04 | Listar catálogo | Especialidades/servicios activos |
| CP-05 | Consultar disponibilidad | Slots futuros no bloqueados |
| CP-06 | Crear cita válida | 201 y estado PENDIENTE |
| CP-07 | Crear cita solapada | 409 sin duplicación |
| CP-08 | Listar citas propias | Solo recursos del paciente |
| CP-09 | Consultar cita ajena | 404/403 sin fuga de datos |
| CP-10 | Cancelar pendiente | 200, estado CANCELADA_PACIENTE |
| CP-11 | Cancelar atendida | 409 |
| CP-12 | Abrir lista sin red tras sincronizar | Caché visible con aviso offline |
| CP-13 | Activar recordatorios | Permiso y solicitudes locales |
| CP-14 | Cancelar cita con recordatorio | Solicitudes pendientes eliminadas |
| CP-15 | Mostrar/ocultar DNI | Oculto por defecto; visible solo voluntariamente |
| CP-16 | Salir del perfil | DNI vuelve a ocultarse |
| CP-17 | Cerrar sesión | Keychain limpiado y login visible |
| CP-18 | Sincronizar cita demo próxima | Recordatorio local pendiente para cinco minutos antes |
| CP-19 | Mantener app en segundo plano | Notificación visible en el centro de notificaciones |

## 4. Matriz de dispositivos

- Simulador iPhone con iOS 17.6.
- Simulador de tamaño compacto.
- Simulador de pantalla grande.
- Modo claro y oscuro.
- Tamaño de texto normal y accesible.
- Red normal, servicio dormido y red desactivada.

## 5. Datos

- Identidad demo autorizada; información clínica, contacto y citas exclusivamente simulados.
- Al menos tres especialidades.
- Servicios con duraciones diferentes.
- Dos o más odontólogos y horarios.
- Citas en estados pendiente, confirmada, atendida y cancelada.
- No usar información clínica, credenciales o contacto reales en capturas o sustentación.

## 6. Criterio de entrada

- API desplegada y health `UP`.
- Migraciones aplicadas.
- Contrato OpenAPI actualizado.
- Build iOS ejecutable.
- Datos demo disponibles.

## 7. Criterio de salida

- Cero defectos bloqueantes o críticos abiertos.
- Compilación limpia en Xcode.
- Cero advertencias de Auto Layout en `Main.storyboard`.
- CP-01 a CP-17 ejecutados con evidencia y todos los P0 conformes.
- CP-18 y CP-19 conformes o registrados como limitación P1 aceptada.
- Pruebas unitarias esenciales aprobadas.
- Health check estable tras reactivación.
- README, OpenAPI, manuales y release notes coherentes.

## 8. Evidencias

Por cada ejecución registrar fecha, versión/commit, dispositivo, datos demo, resultado esperado, resultado obtenido y captura o log no sensible. Los informes por sprint pueden derivarse de esta matriz sin modificar el plan base.

El estado operativo se mantiene en [EVIDENCE_REGISTER.md](EVIDENCE_REGISTER.md) y el resultado consolidado en [INTEGRATION_TEST_REPORT.md](INTEGRATION_TEST_REPORT.md).
