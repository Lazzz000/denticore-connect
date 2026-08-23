# Plan de estabilización y aceptación — Release 0.1

Producto: DentiCore Connect  
Versión candidata: `0.1.0-rc.1`  
Línea base integrada: `61f4730e364b6c567fdaa4f1624cd2193b89a396`  
Fecha de inicio: 23 de agosto de 2026

## 1. Propósito

Cerrar el incremento académico con una versión reproducible, demostrable y documentada. La estabilización no incorpora nuevas funcionalidades: corrige defectos, ejecuta regresión, reúne evidencias y decide si la candidata puede etiquetarse como `v0.1.0`.

## 2. Congelamiento de alcance

Desde esta candidata solo se admiten cambios que cumplan al menos una condición:

- corrigen un defecto bloqueante, crítico o alto;
- evitan pérdida, exposición o inconsistencia de datos;
- corrigen compilación, Auto Layout, contrato REST o despliegue;
- completan documentación o evidencias obligatorias;
- mejoran una presentación sin alterar flujos ni contratos.

Edición de perfil, fotografía, pagos, reprogramación, historia clínica móvil, Watson Assistant, Android y multitenancy comercial permanecen fuera del Release 0.1.

## 3. Entornos controlados

| Entorno | Configuración |
|---|---|
| Backend | Render, rama `feature/backend-mobile-api` |
| Base de datos | PostgreSQL 16 administrado por Render |
| Cliente | Xcode 26.3, iOS mínimo 17.6 |
| Dispositivo principal | Simulador iPhone |
| Datos | Escenario demo, sin información clínica ni credenciales reales |
| Repositorio | `Lazzz000/denticore-connect` |

Antes de cada sesión se debe registrar commit, fecha, simulador, versión de iOS y estado del health check.

## 4. Fases y compuertas

### E0 — Preparación

- Confirmar working tree limpio y commit de prueba.
- Confirmar Render `Live` y health `UP`.
- Confirmar que no existen secretos, tokens o credenciales en archivos o capturas.
- Instalar una compilación limpia en el simulador.

Salida: entorno reproducible y evidencia `EV-01` a `EV-03`.

### E1 — Smoke test

- Abrir la aplicación sin cierre inesperado.
- Iniciar sesión.
- Mostrar Inicio, Citas y Perfil.
- Consumir perfil, especialidades y servicios.
- Confirmar que una falla de red ofrece un estado recuperable.

Salida: ningún defecto bloqueante; evidencias `EV-04` a `EV-07`.

### E2 — Recorrido funcional

- Seleccionar especialidad y servicio.
- Consultar odontólogos y disponibilidad.
- Crear una cita.
- Consultar lista y detalle.
- Cancelar una cita permitida.
- Verificar que una cita atendida sea de solo lectura.
- Mostrar/ocultar DNI y cerrar sesión.

Salida: casos P0 conformes; evidencias `EV-08` a `EV-13`.

### E3 — Integración y regresión

- Verificar API, PostgreSQL, Core Data y Keychain.
- Ejecutar pruebas de backend en CI.
- Ejecutar `⌘B` y las pruebas iOS disponibles.
- Revisar Auto Layout en las pantallas principales.
- Probar arranque en frío de Render.
- Intentar el recordatorio local; si no se observa, registrar el resultado sin bloquear el recorrido P0.

Salida: informe de integración actualizado y defectos clasificados.

### E4 — Aceptación

- Revisar criterios de salida.
- Cerrar o aceptar explícitamente defectos no bloqueantes.
- Completar release notes y manuales.
- Consolidar la rama de release.
- Crear la etiqueta `v0.1.0` únicamente después de la aceptación.

## 5. Clasificación de defectos

| Severidad | Definición | Decisión |
|---|---|---|
| Bloqueante | No compila, no inicia o impide todo el recorrido | Corregir antes de continuar |
| Crítica | Fuga de datos, acceso indebido, corrupción o agenda inconsistente | Corregir antes del release |
| Alta | Falla un requisito P0 sin alternativa razonable | Corregir antes del release |
| Media | Falla una función P1 o existe alternativa controlada | Corregir o aceptar documentadamente |
| Baja | Defecto cosmético o de texto sin impacto funcional | Puede pasar al backlog siguiente |

Cada defecto debe contener versión, pasos, resultado esperado, resultado obtenido, severidad, evidencia y estado.

## 6. Criterios de salida

- Backend CI aprobado para el commit aceptado.
- `⌘B` exitoso en Xcode.
- Cero advertencias de Auto Layout relevantes.
- CP-01 a CP-17 ejecutados; todos los P0 conformes.
- CP-18 y CP-19 conformes o registrados como limitación conocida no bloqueante.
- Ningún defecto bloqueante, crítico o alto abierto.
- Contrato OpenAPI coherente con los endpoints móviles.
- Evidencias almacenadas sin datos sensibles.
- Manual de usuario e instalación revisado.
- Informe de integración con decisión final GO/NO-GO.

## 7. Decisión provisional

Estado actual: **Release Candidate — GO condicionado**.

La aplicación ha completado manualmente su recorrido principal y el backend superó CI. La aceptación definitiva depende de registrar las evidencias críticas, ejecutar la regresión final en Xcode y documentar el resultado del recordatorio local.

