# Documentación de DentiCore Connect

Esta carpeta contiene la documentación vigente y verificable del Release 0.1. La fuente de verdad se distribuye así:

| Documento | Propósito | Audiencia |
|---|---|---|
| [CONTEXT.md](CONTEXT.md) | Contexto, problema, alcance y decisiones | Producto, docentes, equipo |
| [LEAN-CANVAS.md](LEAN-CANVAS.md) | Hipótesis comercial resumida | Producto y negocio |
| [PRD.md](PRD.md) | Requisitos funcionales y no funcionales | Producto, desarrollo, QA |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Arquitectura construida y decisiones | Desarrollo y operaciones |
| [FRONTEND_ARCHITECTURE.md](FRONTEND_ARCHITECTURE.md) | Estructura del cliente iOS y web heredada | Desarrollo móvil/web |
| [DATA_MODEL.md](DATA_MODEL.md) | Esquemas, entidades y migraciones | Backend y base de datos |
| [openapi.yaml](openapi.yaml) | Contrato REST ejecutable | iOS, backend, QA |
| [REGLAS_NEGOCIO.md](REGLAS_NEGOCIO.md) | Reglas de identidad, agenda y privacidad | Todo el equipo |
| [ROUTING_MATRIX.md](ROUTING_MATRIX.md) | Pantallas, segues y endpoints | iOS y QA |
| [UI_DESIGN_SYSTEM.md](UI_DESIGN_SYSTEM.md) | Tokens y patrones visuales | iOS y diseño |
| [TEST_PLAN.md](TEST_PLAN.md) | Estrategia, casos y criterio de salida | QA y desarrollo |
| [CONTINUOUS_INTEGRATION.md](CONTINUOUS_INTEGRATION.md) | Flujo de integración continua | Desarrollo |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Ejecución local y Render | Desarrollo y operaciones |
| [RELEASE_NOTES.md](RELEASE_NOTES.md) | Incremento, límites y pendientes | Todos |

## Reglas de mantenimiento

1. El código implementado y `openapi.yaml` deben coincidir.
2. Una modificación de endpoint exige actualizar OpenAPI, modelos iOS y pruebas.
3. Una modificación de base de datos exige una nueva migración Flyway; nunca se edita una migración ya aplicada.
4. El README describe únicamente capacidades construidas o explícitamente planificadas.
5. Los diagramas históricos de `diagrams/` se conservan como antecedentes; la arquitectura vigente es la descrita en `ARCHITECTURE.md`.
6. No se registran credenciales, tokens ni datos reales de pacientes.

## Estado documental

Versión: `0.1.0-rc.1`
Fecha de corte: 23 de agosto de 2026
Línea base heredada: `v0.0.0-legacy-daw2`
