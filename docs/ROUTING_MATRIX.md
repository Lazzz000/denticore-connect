# Matriz de navegación e integración

## Pantallas iOS

| Pantalla | Controlador | Entrada | Salida/Segue | Servicio |
|---|---|---|---|---|
| Login | `LoginViewController` | DNI, contraseña | `showMain` | `POST /auth/login` |
| Inicio | `HomeViewController` | Sesión activa | Tabs, especialidades, detalle | Perfil y citas |
| Especialidades | `SpecialtiesViewController` | Sesión activa | `showServices` | `GET /especialidades` |
| Servicios | `ServicesViewController` | `Specialty` | `showAppointment` | `GET /servicios` |
| Programar cita | `AppointmentViewController` | `Specialty`, `DentalService` | Confirmación | Odontólogos, disponibilidad, citas |
| Mis citas | `AppointmentsListViewController` | Sesión activa | `showAppointmentDetail` | `GET /pacientes/me/citas` |
| Detalle | `AppointmentDetailViewController` | `PatientAppointment` | Regreso al listado | GET/PATCH de cita |
| Perfil | `ProfileViewController` | Sesión activa | Logout | `GET /pacientes/me` |

## Tabs autenticados

| Índice | Título | Controlador raíz | Icono SF Symbols |
|---:|---|---|---|
| 0 | Inicio | `HomeViewController` | `house.fill` |
| 1 | Citas | `AppointmentsListViewController` | `calendar` |
| 2 | Perfil | `ProfileViewController` | `person.crop.circle` |

Cada tab posee su propio `UINavigationController`, lo que conserva una pila de navegación independiente.

## Contrato por flujo

| Flujo | Método y ruta | Autorización | Resultado |
|---|---|---|---|
| Login | `POST /auth/login` | Público | Token y clínica |
| Perfil | `GET /pacientes/me` | Paciente | Datos propios |
| Especialidades | `GET /especialidades` | Autenticado | Catálogo activo |
| Servicios | `GET /servicios?especialidadId=` | Autenticado | Servicios filtrados |
| Odontólogos | `GET /pacientes/me/odontologos?especialidadId=` | Paciente | Profesionales válidos |
| Disponibilidad | `GET /pacientes/me/disponibilidad` | Paciente | Slots disponibles |
| Listar citas | `GET /pacientes/me/citas` | Paciente | Citas propias |
| Crear cita | `POST /pacientes/me/citas` | Paciente | Cita pendiente |
| Detalle | `GET /pacientes/me/citas/{id}` | Paciente propietario | Cita propia |
| Cancelar | `PATCH /pacientes/me/citas/{id}/cancelacion` | Paciente propietario | Cita cancelada |
| Logout | `POST /auth/logout` | Autenticado | `204` |

## Manejo común

- `400`: mostrar validación recuperable.
- `401`: finalizar sesión y volver al login.
- `403`: informar que la operación no está permitida.
- `404`: recurso no disponible.
- `409`: horario ocupado o transición inválida.
- `5xx`/red: ofrecer reintento; usar caché únicamente en el listado de citas.
