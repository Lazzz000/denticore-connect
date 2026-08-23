# DentiCore Connect

DentiCore Connect es una plataforma B2B2C de continuidad de atención dental. El Release 0.1 permite que un paciente autenticado consulte la oferta de una clínica, programe y gestione citas desde una aplicación iOS nativa, mientras el backend conserva las reglas de identidad, agenda y aislamiento por clínica.

> Estado: **Release 0.1 Candidate** · Cliente iOS funcional · API y PostgreSQL desplegados en Render.

## Producto

- **Cliente comercial:** clínica dental pequeña o mediana.
- **Usuario móvil:** paciente vinculado a una clínica.
- **Problema atendido:** reservas y seguimiento de citas dispersos entre llamadas, mensajería y registros manuales.
- **Propuesta de valor:** autogestión de citas, recordatorios locales y continuidad de información desde un canal móvil seguro.
- **Alcance multiclínica:** el modelo ya incorpora clínica, sede y membresía de usuario; el Release 0.1 opera como piloto con una clínica y no constituye todavía un SaaS multitenant completo.

## Capacidades del Release 0.1

- Inicio de sesión con DNI y contraseña.
- JWT almacenado en Keychain y cierre de sesión centralizado.
- Dashboard del paciente y navegación inferior Inicio/Citas/Perfil.
- Consulta de especialidades, servicios, odontólogos y disponibilidad.
- Programación de citas con protección frente a solapamientos.
- Listado, detalle y cancelación de citas propias.
- Caché de citas con Core Data para lectura sin conexión.
- Recordatorios locales mediante UserNotifications.
- Perfil de solo lectura con DNI protegido y revelado voluntario.
- Escenario demostrativo realista con identidad autorizada, sede SJL, historial atendido y cita próxima para verificar recordatorios locales.
- API Spring Boot con autorización por rol y propiedad del recurso.
- Migraciones Flyway y datos demostrativos controlados por perfil.
- Despliegue reproducible en Render y CI del backend en GitHub Actions.

## Arquitectura actual

| Componente | Tecnología | Responsabilidad |
|---|---|---|
| Aplicación iOS | Swift, UIKit, Storyboard, Core Data | Experiencia del paciente |
| API | Java 17, Spring Boot, Spring Security, JPA | Identidad, catálogo, agenda y reglas |
| Base de datos | PostgreSQL 16, Flyway | Persistencia, integridad y migraciones |
| Back-office heredado | Angular | Operación web preexistente de la clínica |
| Infraestructura | Docker, Render, GitHub Actions | Construcción, despliegue y verificación |

La implementación es un **monolito modular**, no un conjunto de microservicios. RabbitMQ, API Gateway, pagos y facturación electrónica no forman parte del Release 0.1.

## Repositorio

```text
.
├── ios/                         # Aplicación iOS UIKit/Storyboard
├── backend/                     # API Spring Boot y migraciones Flyway
├── frontend/                    # Back-office Angular heredado
├── database/                    # Referencia del esquema heredado
├── docs/                        # Documentación vigente del producto
├── .github/workflows/           # Integración continua
├── docker-compose.yml           # PostgreSQL local
└── render.yaml                  # Blueprint de despliegue
```

## Ejecución rápida

### iOS

1. Abrir `ios/DentiCoreConnect/DentiCoreConnect.xcodeproj` en Xcode 26.3 o compatible.
2. Seleccionar un simulador con iOS 17.6 o superior.
3. Confirmar `API_BASE_URL` en `Info.plist`.
4. Ejecutar con `⌘R`.

La configuración incluida consume:

```text
https://denticore-connect-api.onrender.com/api/v1
```

### Backend local

```bash
read -s POSTGRES_PASSWORD
read -s DENTICORE_LOCAL_JWT_SECRET
export POSTGRES_PASSWORD DENTICORE_LOCAL_JWT_SECRET
docker compose up -d
cd backend
DB_PASSWORD="$POSTGRES_PASSWORD" \
JWT_SIGNING_SECRET="$DENTICORE_LOCAL_JWT_SECRET" \
./mvnw spring-boot:run
```

Flyway crea y evoluciona la estructura. Hibernate utiliza `ddl-auto=validate`; no modifica automáticamente la base de datos.

### Verificación del servicio desplegado

```text
GET https://denticore-connect-api.onrender.com/api/v1/actuator/health
```

La instancia gratuita de Render puede requerir un tiempo de reactivación después de un periodo de inactividad.

## Documentación

El índice completo se encuentra en [`docs/README.md`](docs/README.md). Los documentos principales son:

- [`docs/PRD.md`](docs/PRD.md): requisitos del producto.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): arquitectura construida.
- [`docs/openapi.yaml`](docs/openapi.yaml): contrato REST del Release 0.1.
- [`docs/REGLAS_NEGOCIO.md`](docs/REGLAS_NEGOCIO.md): invariantes funcionales.
- [`docs/UI_DESIGN_SYSTEM.md`](docs/UI_DESIGN_SYSTEM.md): sistema visual iOS.
- [`docs/TEST_PLAN.md`](docs/TEST_PLAN.md): estrategia y compuerta de calidad.
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md): ejecución y despliegue.
- [`docs/RELEASE_NOTES.md`](docs/RELEASE_NOTES.md): contenido y limitaciones del release.

## Seguridad y datos de demostración

- No se almacenan contraseñas en texto plano.
- El token del paciente se conserva únicamente en Keychain.
- Los datos demostrativos deben ser ficticios.
- El nombre ficticio puede configurarse mediante `DEMO_PATIENT_NAMES` y `DEMO_PATIENT_SURNAMES` sin recompilar.
- Las credenciales demo se configuran como variables de entorno; no deben registrarse en Git.
- El DNI permanece oculto por defecto en el perfil y nunca debe incluirse en notificaciones.

## Estado de verificación

- La API desplegada responde `UP` en Actuator.
- El flujo iOS login → dashboard → catálogo → reserva → citas → detalle → cancelación → perfil fue validado manualmente.
- La compilación final de esta iteración debe confirmarse en Xcode/macOS antes de etiquetar `v0.1.0-rc.1`.
