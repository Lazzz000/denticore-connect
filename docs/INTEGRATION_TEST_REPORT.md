# Informe de pruebas de integración — Release 0.1

Estado: En ejecución  
Versión evaluada: `0.1.0-rc.1`  
Commit inicial: `61f4730e364b6c567fdaa4f1624cd2193b89a396`

## 1. Objetivo

Comprobar que los subsistemas iOS, API Spring Boot, PostgreSQL, seguridad, persistencia local y despliegue colaboran correctamente en el recorrido del paciente.

## 2. Subsistemas

| Subsistema | Responsabilidad | Interfaz |
|---|---|---|
| iOS UIKit/Storyboard | Interacción, navegación y presentación | HTTPS/JSON |
| Keychain | Sesión local segura | Token JWT |
| Core Data | Caché local de citas | Modelos persistentes |
| Spring Boot | Seguridad y reglas de negocio | REST `/api/v1` |
| PostgreSQL | Integridad, agenda y auditoría | JPA/Flyway |
| Render | Ejecución pública y health | HTTPS |
| UserNotifications | Recordatorios locales | API nativa de iOS |

## 3. Entorno

| Elemento | Valor |
|---|---|
| Backend | `https://denticore-connect-api.onrender.com/api/v1` |
| Base de datos | PostgreSQL 16 |
| Cliente | Xcode 26.3 / iOS 17.6 o superior |
| Datos | Escenario demo controlado |
| CI | GitHub Actions, workflow Backend CI |

## 4. Resultados provisionales

Los estados `Reportado` reflejan validaciones manuales comunicadas durante el desarrollo; deben convertirse a `Conforme` al adjuntar la evidencia indicada.

| ID | Integración | Resultado esperado | Estado | Evidencia |
|---|---|---|---|---|
| INT-01 | iOS → Auth → PostgreSQL | Login entrega JWT y clínica | Reportado | EV-05 |
| INT-02 | iOS → Perfil/Catálogo | Datos propios y catálogos visibles | Reportado | EV-06/EV-08 |
| INT-03 | iOS → Agenda | Odontólogos y slots válidos | Reportado | EV-09 |
| INT-04 | iOS → Crear cita → PostgreSQL | Cita PENDIENTE persistida | Reportado | EV-10 |
| INT-05 | iOS → Listado/Detalle | Datos completos y propiedad respetada | Reportado | EV-11 |
| INT-06 | iOS → Cancelación → Auditoría | Cambio de estado sin DELETE físico | Reportado | EV-12 |
| INT-07 | API → Restricción de agenda | Conflicto rechazado con 409 | Pendiente | EV-20 |
| INT-08 | API → Autorización | Credenciales inválidas responden 401 | Pendiente | EV-19 |
| INT-09 | API → Core Data | Caché visible sin conexión | Pendiente | EV-14 |
| INT-10 | API → UserNotifications | Recordatorio local programado | Parcial | EV-15/EV-16 |
| INT-11 | GitHub → CI | Backend y migraciones superan workflow | Conforme | EV-02 |
| INT-12 | GitHub → Render → Health | Commit desplegado y servicio UP | Reportado | EV-03 |

## 5. Incidencias

### INC-01 — Notificación local no observada

- Severidad: Media.
- Estado: En verificación.
- Impacto: no afecta autenticación, consulta, creación o cancelación de citas.
- Comportamiento esperado: la app sincroniza una cita activa y presenta el recordatorio en segundo plano.
- Acción: sincronizar el Blueprint, verificar permiso, actualizar Mis citas y dejar la app en segundo plano antes del disparo.
- Decisión: si no se reproduce, documentar como limitación conocida del entorno demostrativo y mover una prueba controlada al backlog.

## 6. Seguridad y privacidad

- El token se conserva en Keychain.
- Core Data no almacena contraseñas ni JWT.
- El backend verifica rol, clínica y propiedad.
- La cancelación no elimina la cita y conserva auditoría.
- Las evidencias no deben revelar credenciales, tokens o DNI completo.
- Los datos clínicos y citas son simulados.

## 7. Criterio de aceptación

El informe cambia a `Aprobado` cuando:

- INT-01 a INT-06, INT-08, INT-11 e INT-12 estén conformes;
- INT-07 tenga evidencia de rechazo de conflicto o transición inválida;
- INT-09 esté conforme o exista una incidencia aceptada;
- INT-10 esté conforme o sea aceptada como limitación P1;
- no existan defectos bloqueantes, críticos o altos.

## 8. Conclusión provisional

La integración principal iOS–API–PostgreSQL es funcional según las ejecuciones manuales reportadas, y el backend superó CI. La candidata permanece en **GO condicionado** hasta completar capturas, pruebas negativas y verificación offline.

