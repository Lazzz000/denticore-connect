# Registro maestro de evidencias — Release 0.1

## 1. Convención

Los archivos se almacenan en `docs/evidence/release-0.1/` con el formato:

```text
EV-XX_descripcion_YYYYMMDD.ext
```

Ejemplo: `EV-04_login_exitoso_20260823.png`.

No deben aparecer contraseñas, JWT, secretos, correos privados ni un DNI completo. Para evidenciar el perfil se mantiene el DNI oculto.

## 2. Estados

| Estado | Significado |
|---|---|
| Pendiente | Aún no ejecutado o sin evidencia |
| Reportado | Flujo confirmado manualmente, archivo pendiente |
| Conforme | Ejecutado y evidencia almacenada |
| No conforme | Resultado distinto del esperado |
| No aplica | Justificado fuera del alcance |

## 3. Matriz

| ID | Evidencia requerida | Caso relacionado | Estado inicial | Archivo/URL |
|---|---|---|---|---|
| EV-01 | Commit candidato y repositorio limpio | Configuración | Pendiente | — |
| EV-02 | Backend CI aprobado | Integración backend | Conforme | [PR #4](https://github.com/Lazzz000/denticore-connect/pull/4) / Backend CI #94 |
| EV-03 | Render `Live` y health `UP` | Despliegue | Reportado | Captura pendiente |
| EV-04 | Build Succeeded en Xcode | Compilación iOS | Reportado | Captura pendiente |
| EV-05 | Login exitoso sin mostrar contraseña | CP-01 | Reportado | Captura pendiente |
| EV-06 | Inicio con paciente y clínica | RF-03/RF-12 | Reportado | Captura pendiente |
| EV-07 | Tabs Inicio, Citas y Perfil | RF-12 | Reportado | Captura pendiente |
| EV-08 | Especialidades y servicios desde API | CP-04 | Reportado | Captura pendiente |
| EV-09 | Odontólogo y disponibilidad | CP-05 | Reportado | Captura pendiente |
| EV-10 | Confirmación de cita creada | CP-06 | Reportado | Captura pendiente |
| EV-11 | Lista, detalle e historial atendido | CP-08/CP-11 | Reportado | Captura pendiente |
| EV-12 | Cancelación y nuevo estado | CP-10 | Reportado | Captura pendiente |
| EV-13 | Perfil con DNI oculto y logout | CP-15/CP-17 | Reportado | Captura pendiente |
| EV-14 | Lectura desde Core Data sin red | CP-12 | Pendiente | — |
| EV-15 | Permiso de notificaciones autorizado | CP-13 | Reportado | Captura pendiente |
| EV-16 | Recordatorio visible en segundo plano | CP-18/CP-19 | Pendiente | — |
| EV-17 | Pruebas XCTest ejecutadas | Pruebas iOS | Pendiente | — |
| EV-18 | Cero advertencias relevantes de Auto Layout | Calidad UI | Reportado | Captura pendiente |
| EV-19 | Respuesta 401 a credenciales inválidas | CP-02 | Pendiente | — |
| EV-20 | Respuesta 409 a conflicto o transición inválida | CP-07/CP-11 | Pendiente | — |

## 4. Ficha por ejecución

Copiar esta ficha debajo de la evidencia correspondiente o al informe de prueba:

```text
Evidencia:
Fecha y hora:
Commit:
Responsable:
Entorno/dispositivo:
Precondiciones:
Pasos:
Resultado esperado:
Resultado obtenido:
Estado:
Archivo o URL:
Observaciones:
```

## 5. Evidencias mínimas para sustentación

La presentación debe priorizar EV-02 a EV-13. EV-14 demuestra persistencia local y EV-16 mejora la demostración, pero una limitación documentada en notificaciones no invalida los flujos P0 del producto.
