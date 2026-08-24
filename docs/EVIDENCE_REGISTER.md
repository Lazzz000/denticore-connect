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
| EV-03 | Render `Live` y health `UP` | Despliegue | Conforme | Archivo privado: `EV-03_render_health_up_20260823.png` |
| EV-04 | Build Succeeded en Xcode | Compilación iOS | Conforme | Archivo privado: `EV-04_xcode_build_succeeded_20260823.png` |
| EV-05 | Login exitoso sin mostrar contraseña | CP-01 | Reportado | Recapturar sin DNI ni contraseña visibles |
| EV-06 | Inicio con paciente y clínica | RF-03/RF-12 | Conforme | Archivo privado: `EV-06_inicio_paciente_clinica_20260823.png` |
| EV-07 | Tabs Inicio, Citas y Perfil | RF-12 | Conforme | Archivo privado: `EV-07_tab_bar_20260823.png` |
| EV-08 | Especialidades y servicios desde API | CP-04 | Conforme | Archivos privados: `EV-08_especialidades_20260823.png`, `EV-08_servicios_20260823.png` |
| EV-09 | Odontólogo y disponibilidad | CP-05 | Conforme | Archivo privado: `EV-09_agendamiento_disponibilidad_20260823.png` |
| EV-10 | Confirmación de cita creada | CP-06 | Conforme | Archivo privado: `EV-10_cita_creada_20260823.png` |
| EV-11 | Lista, detalle e historial atendido | CP-08/CP-11 | Conforme | Archivos privados: `EV-11_lista_historial_citas_20260823.png`, `EV-11_detalle_cita_20260823.png` |
| EV-12 | Cancelación y nuevo estado | CP-10 | Conforme | Archivos privados: `EV-12_confirmacion_cancelacion_20260823.png`, `EV-12_cita_cancelada_20260823.png` |
| EV-13 | Perfil con DNI oculto y logout | CP-15/CP-17 | Reportado | Recapturar sin correo privado visible |
| EV-14 | Lectura desde Core Data sin red | CP-12 | Pendiente | — |
| EV-15 | Permiso de notificaciones autorizado | CP-13 | Conforme | Archivos privados: `EV-15_recordatorios_activos_20260823.png`, `EV-15_permiso_notificaciones_20260823.png` |
| EV-16 | Recordatorio visible en segundo plano | CP-18/CP-19 | Pendiente | — |
| EV-17 | Pruebas XCTest ejecutadas | Pruebas iOS | Pendiente | — |
| EV-18 | Cero advertencias relevantes de Auto Layout | Calidad UI | Pendiente | Recapturar tras aplicar el ajuste de prioridades verticales |
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

Las capturas se conservan fuera del repositorio público y su integridad se acredita mediante [EVIDENCE_MANIFEST.sha256](evidence/release-0.1/EVIDENCE_MANIFEST.sha256). EV-05 y EV-13 deben recapturarse porque mostraban datos que la política exige resguardar. EV-18 tampoco se aceptó: la imagen recibida no acreditaba la ausencia de advertencias.
