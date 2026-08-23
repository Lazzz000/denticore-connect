# Despliegue y ejecución

## 1. Entorno desplegado

| Recurso | Valor |
|---|---|
| API | `https://denticore-connect-api.onrender.com` |
| Base API | `/api/v1` |
| Health | `/api/v1/actuator/health` |
| Base de datos | PostgreSQL 16 administrado por Render |
| Región | Oregon |
| Configuración | `render.yaml` |

## 2. Render

El Blueprint crea:

- servicio web Docker `denticore-connect-api`;
- base `denticore-connect-db`;
- secreto JWT generado;
- conexión `DATABASE_URL`;
- perfil `demo` y datos demostrativos;
- health check y despliegue automático por commit.

Variables manuales requeridas para el paciente demo:

```text
DEMO_PATIENT_DNI
DEMO_PATIENT_EMAIL
DEMO_PATIENT_PASSWORD
```

No registrar sus valores en el repositorio.

Variables de presentación, configuradas inicialmente por el Blueprint:

```text
DEMO_PATIENT_NAMES=Carlos Miguel
DEMO_PATIENT_SURNAMES=Lazo Dominguez
```

Pueden modificarse desde Render para utilizar otra identidad ficticia. En el siguiente despliegue, el bootstrap actualizará el usuario existente sin cambiar su DNI, credenciales, citas ni relaciones.

## 3. Base de datos

Al iniciar el backend:

1. `DatabaseUrlAdapter` traduce `DATABASE_URL` cuando corresponde;
2. Flyway valida y aplica migraciones pendientes;
3. el perfil demo aplica datos repetibles;
4. JPA valida el mapeo sin alterar tablas;
5. Actuator publica el estado de salud.

No se ejecuta manualmente `DATABASE_SCHEMA.sql` en Render.

## 4. Backend local

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

URL local:

```text
http://localhost:8080/api/v1
```

Para cargar demo local, activar `SPRING_PROFILES_ACTIVE=demo`, configurar `FLYWAY_DEMO_LOCATION=,classpath:db/demo` y suministrar las tres variables privadas. El nombre y apellido usan valores ficticios predeterminados si no se especifican.

## 5. iOS

- Abrir `ios/DentiCoreConnect/DentiCoreConnect.xcodeproj`.
- Target mínimo iOS 17.6.
- `API_BASE_URL` está en `Info.plist`.
- Ejecutar en un simulador iPhone.
- La primera solicitud puede demorar mientras Render reactiva la instancia.

## 6. Verificación posterior

1. Consultar health hasta obtener `UP`.
2. Ejecutar login demo.
3. Consultar perfil y catálogo.
4. Verificar la cita próxima generada para la demostración y las tres citas atendidas del historial.
5. Confirmar que las citas atendidas no ofrecen cancelación.
6. Crear una cita futura, consultar su detalle y cancelarla.

### Demostración de recordatorio local

El perfil `demo` regenera al iniciar el backend una cita pendiente con aproximadamente 15 minutos de anticipación. Para mostrar la notificación:

1. Reiniciar o desplegar el backend poco antes de la exposición y esperar que `/api/v1/actuator/health` responda `UP`.
2. Iniciar sesión en iOS, autorizar notificaciones y abrir Inicio o Mis citas para sincronizar la agenda.
3. Verificar que la cita `Profilaxis y limpieza dental` aparece próxima.
4. Enviar la aplicación a segundo plano. El recordatorio se programa cinco minutos antes de la cita y queda visible en el centro de notificaciones del simulador.

La cita usa el canal interno `DEMO_NOTIFICATION` y se actualiza en lugar de duplicarse en cada arranque.
7. Confirmar registros en la API y caché iOS.

## 7. Recuperación

- Si Flyway falla, revisar checksum y migración; no editar una migración aplicada.
- Si Render no conecta, revisar `DATABASE_URL` y estado de la base.
- Si el login falla después del arranque, revisar variables demo sin imprimirlas.
- Si iOS muestra timeout, comprobar health antes de modificar código.
