# Reglas de negocio

## 1. Identidad y sesión

- RN-01: El DNI de autenticación contiene exactamente ocho dígitos.
- RN-02: La contraseña aceptada por la API contiene entre 8 y 72 caracteres.
- RN-03: Las credenciales inválidas producen `401` sin identificar cuál campo falló.
- RN-04: Solo el rol `PACIENTE` puede usar la fachada `/pacientes/me`.
- RN-05: Cada petición protegida resuelve usuario y clínica desde el JWT; el cliente no selecciona arbitrariamente `idPaciente` o `idClinica`.
- RN-06: Un `401` invalida la sesión local y devuelve al login.
- RN-07: El JWT se almacena únicamente en Keychain.

## 2. Clínica y catálogo

- RN-08: El paciente opera dentro de una membresía activa `usuario_clinica`.
- RN-09: Solo se muestran especialidades y servicios activos y habilitados para web/móvil.
- RN-10: Los odontólogos deben estar activos, pertenecer a la clínica y atender la especialidad seleccionada.
- RN-11: La moneda de referencia del Release 0.1 es PEN.

## 3. Disponibilidad

- RN-12: La fecha consultada no puede ser anterior a la fecha actual de la clínica.
- RN-13: Los slots se generan desde horarios activos y vigentes del odontólogo.
- RN-14: Los bloqueos de agenda y citas activas eliminan slots incompatibles.
- RN-15: La duración del servicio determina `fechaHoraFin`.
- RN-16: La hora se interpreta en la zona `America/Lima` del piloto y se intercambia con offset ISO 8601.

## 4. Creación de cita

- RN-17: La cita debe comenzar en el futuro.
- RN-18: El servicio y el odontólogo deben ser válidos para la clínica autenticada.
- RN-19: El horario solicitado debe encontrarse disponible al momento de confirmar.
- RN-20: La base de datos impide solapamientos de citas activas para el mismo odontólogo.
- RN-21: Una cita creada por el paciente inicia en `PENDIENTE`.
- RN-22: La nota del paciente es opcional y tiene máximo 300 caracteres.
- RN-23: La creación genera trazabilidad en `crm.cita_evento`.

## 5. Estados y cancelación

Estados vigentes:

- `PENDIENTE`
- `CONFIRMADA`
- `EN_SALA`
- `EN_CURSO`
- `ATENDIDA`
- `CANCELADA_PACIENTE`
- `CANCELADA_CLINICA`
- `NO_ASISTIO`

Reglas:

- RN-24: El paciente solo cancela citas `PENDIENTE` o `CONFIRMADA`.
- RN-25: Cancelar es una transición de estado mediante `PATCH`; no elimina la cita.
- RN-26: El motivo es opcional y tiene máximo 300 caracteres.
- RN-27: La cancelación registra actor, fecha, motivo y evento.
- RN-28: El endpoint `DELETE` no se usa para una cancelación porque el recurso continúa existiendo como registro auditado.

## 6. Propiedad y privacidad

- RN-29: Un paciente solo consulta citas vinculadas a su usuario y clínica.
- RN-30: Una cita ajena se trata como recurso no accesible.
- RN-31: La app oculta el DNI por defecto; el usuario puede revelarlo en su propia pantalla de perfil.
- RN-32: Al abandonar el perfil, el DNI vuelve a ocultarse.
- RN-33: DNI, token y datos clínicos no se incluyen en notificaciones locales.
- RN-34: Los datos de demostración son ficticios.

## 7. Caché y recordatorios

- RN-35: Core Data conserva la última lista de citas recibida con éxito.
- RN-36: La caché nunca autoriza una escritura remota ni confirma disponibilidad.
- RN-37: Solo citas activas y futuras generan recordatorios.
- RN-38: Cancelar una cita elimina sus recordatorios pendientes.
- RN-39: Denegar notificaciones no impide utilizar el resto de la aplicación.
