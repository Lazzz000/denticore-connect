# Manual de usuario e instalación — DentiCore Connect 0.1

## 1. Descripción

DentiCore Connect es una aplicación iOS para pacientes de una clínica dental. Permite iniciar sesión, consultar especialidades y servicios, revisar disponibilidad, programar citas, consultar el historial, cancelar citas permitidas y administrar recordatorios locales.

La aplicación es una herramienta de autogestión. No diagnostica, prescribe ni reemplaza la atención de un profesional.

## 2. Requisitos

### Usuario

- iPhone o simulador con iOS 17.6 o superior.
- Conexión a internet para autenticación y operaciones remotas.
- Credenciales de paciente habilitadas.
- Permiso de notificaciones si desea recordatorios.

### Desarrollo

- macOS con Xcode 26.3 o compatible.
- Git.
- Acceso HTTPS al backend desplegado.
- Para backend local: Java 17, Docker y Docker Compose.

## 3. Instalación iOS para demostración

1. Obtener el repositorio:

   ```bash
   git clone https://github.com/Lazzz000/denticore-connect.git
   cd denticore-connect
   git switch feature/ios-storyboard-mvp
   ```

2. Abrir:

   ```text
   ios/DentiCoreConnect/DentiCoreConnect.xcodeproj
   ```

3. Seleccionar el target `DentiCoreConnect` y un simulador iPhone.
4. Confirmar deployment target iOS 17.6.
5. Verificar que `API_BASE_URL` apunte a:

   ```text
   https://denticore-connect-api.onrender.com/api/v1
   ```

6. Ejecutar `Product > Clean Build Folder` si existe una instalación anterior.
7. Compilar con `⌘B`.
8. Ejecutar con `⌘R`.

No es necesario configurar un Team para ejecutar en simulador. Un dispositivo físico sí requiere firma válida.

## 4. Verificación del backend

Antes de iniciar la demostración, abrir:

```text
https://denticore-connect-api.onrender.com/api/v1/actuator/health
```

Continuar cuando responda `status: UP`. El plan gratuito puede demorar durante el primer acceso.

La base de datos se construye mediante Flyway durante el arranque. No se debe ejecutar manualmente `DATABASE_SCHEMA.sql` en Render.

## 5. Inicio de sesión

1. Abrir DentiCore Connect.
2. Escribir el DNI y contraseña proporcionados para el entorno demo.
3. Pulsar **Ingresar**.
4. Esperar el indicador de carga durante un posible arranque en frío.

La aplicación mostrará Inicio después de validar el rol PACIENTE y el contexto de clínica. Las credenciales no deben aparecer en capturas.

## 6. Navegación principal

### Inicio

Muestra:

- logo e identidad del producto;
- saludo con el primer nombre del paciente;
- clínica asociada;
- próxima cita activa;
- acceso a especialidades y a todas las citas.

### Citas

Muestra citas futuras e históricas. Al seleccionar una cita se visualizan servicio, especialidad, odontólogo, sede, fecha, estado y nota.

Solo una cita `PENDIENTE` o `CONFIRMADA` ofrece cancelación. Una cita `ATENDIDA` se conserva como historial y no puede cancelarse.

### Perfil

Muestra datos de solo lectura, clínica, estado de notificaciones y cierre de sesión. El DNI permanece oculto hasta pulsar la acción de revelado y vuelve a ocultarse al salir de la pantalla.

## 7. Consultar y programar una cita

1. En Inicio, pulsar **Explorar especialidades**.
2. Seleccionar una especialidad.
3. Seleccionar un servicio.
4. Elegir odontólogo.
5. Elegir una fecha válida.
6. Seleccionar un horario disponible.
7. Añadir una nota opcional.
8. Pulsar **Programar cita**.
9. Confirmar el mensaje de éxito.

El horario debe provenir de la disponibilidad del backend. Si otro usuario lo ocupa primero, la API responderá conflicto y la aplicación actualizará las opciones.

## 8. Cancelar una cita

1. Abrir la pestaña Citas.
2. Seleccionar una cita pendiente o confirmada.
3. Pulsar **Cancelar cita**.
4. Confirmar la decisión.
5. Volver al listado y verificar el nuevo estado.

La operación utiliza `PATCH`; no elimina el registro y conserva trazabilidad.

## 9. Recordatorios

1. Abrir Perfil.
2. Pulsar **Activar recordatorios**.
3. Autorizar alertas, sonidos y centro de notificaciones.
4. Regresar a Inicio o Citas para sincronizar la agenda.
5. Dejar la aplicación en segundo plano antes del recordatorio.

Si el permiso fue denegado, usar **Abrir Configuración**. Los recordatorios son locales; no son notificaciones push del servidor.

## 10. Funcionamiento sin conexión

Después de una sincronización exitosa, la pestaña Citas conserva una copia en Core Data. Sin red puede mostrar los datos almacenados con una indicación offline. Crear, cancelar o actualizar datos requiere conexión.

## 11. Cerrar sesión

1. Abrir Perfil.
2. Pulsar **Cerrar sesión**.
3. Confirmar.

La aplicación elimina el JWT de Keychain, limpia el contexto de sesión y vuelve al Login.

## 12. Solución de problemas

| Problema | Acción |
|---|---|
| Login demora | Verificar health y esperar el arranque en frío de Render |
| Error de conexión | Confirmar internet y `API_BASE_URL`; usar Reintentar |
| No aparecen horarios | Elegir otra fecha/odontólogo y actualizar disponibilidad |
| Cita no puede cancelarse | Revisar estado; atendidas y canceladas son de solo lectura |
| No aparece notificación | Verificar permiso, actualizar Citas y dejar app en segundo plano |
| Logo/icono anterior | Limpiar build, eliminar app del simulador y reinstalar |
| Datos antiguos | Actualizar Citas; si no hay red se muestra la caché local |
| Sesión finalizada | Volver a iniciar sesión; un 401 limpia el token local |

## 13. Instalación backend local opcional

1. Definir secretos localmente sin escribirlos en archivos versionados.
2. Levantar PostgreSQL con `docker compose up -d`.
3. Entrar en `backend`.
4. Ejecutar `./mvnw spring-boot:run` con las variables indicadas en [DEPLOYMENT.md](DEPLOYMENT.md).
5. Verificar `http://localhost:8080/api/v1/actuator/health`.
6. Modificar temporalmente `API_BASE_URL` solo si el simulador consumirá el backend local.

## 14. Desinstalación

En el simulador, mantener pulsado el icono y elegir eliminar aplicación. Esto elimina el contenedor y la caché Core Data; los elementos de Keychain pueden persistir según el entorno y deben limpiarse desde el flujo de cierre de sesión o reiniciando el simulador. Eliminar la aplicación no elimina registros del backend.

## 15. Soporte documental

- Contrato API: [openapi.yaml](openapi.yaml)
- Arquitectura: [ARCHITECTURE.md](ARCHITECTURE.md)
- Despliegue: [DEPLOYMENT.md](DEPLOYMENT.md)
- Reglas: [REGLAS_NEGOCIO.md](REGLAS_NEGOCIO.md)
- Pruebas: [TEST_PLAN.md](TEST_PLAN.md)
