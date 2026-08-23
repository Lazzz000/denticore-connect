# Contexto del producto

## 1. Visión

DentiCore Connect evoluciona una solución odontológica web preexistente hacia una plataforma de relación entre clínicas y pacientes. El producto completo combina un back-office web, una API central y clientes móviles. El Release 0.1 introduce la aplicación iOS nativa orientada al paciente.

## 2. Problema

En clínicas dentales pequeñas y medianas, la reserva y el seguimiento de citas suelen depender de llamadas, mensajería y coordinación manual. Esto genera:

- dependencia del horario del personal;
- reprogramaciones y cancelaciones difíciles de rastrear;
- poca visibilidad del paciente sobre sus próximas atenciones;
- recordatorios manuales;
- riesgo de cruces de agenda;
- datos distribuidos entre canales.

## 3. Usuarios e interesados

| Actor | Necesidad | Canal en el producto |
|---|---|---|
| Paciente | Autogestionar citas y recordatorios | Aplicación iOS |
| Recepción/administración | Mantener agenda y catálogos | Back-office web heredado |
| Odontólogo | Consultar agenda y registrar atención | Back-office web heredado |
| Clínica | Reducir fricción y ordenar la relación con pacientes | Plataforma completa |
| Equipo de desarrollo | Mantener una solución demostrable y evolucionable | Repositorio y pipeline |

## 4. Posicionamiento

El producto es B2B2C:

- la clínica es el cliente potencial del servicio;
- el paciente es el usuario de la aplicación;
- la aplicación iOS es un canal, no la totalidad del sistema;
- el modelo futuro puede comercializarse por clínica, sede o profesionales activos.

## 5. Alcance del Release 0.1

El release valida un recorrido vertical completo:

1. autenticar al paciente;
2. recuperar su contexto de clínica;
3. explorar especialidades y servicios;
4. seleccionar odontólogo, fecha y horario;
5. crear una cita propia;
6. consultar citas con soporte offline;
7. revisar el detalle y cancelar cuando las reglas lo permitan;
8. recibir recordatorios locales;
9. consultar el perfil y cerrar sesión.

## 6. Límites

Quedan fuera del Release 0.1:

- edición del perfil;
- fotografía remota o Cloudinary;
- reprogramación directa;
- pagos y facturación electrónica;
- historia clínica u odontograma en iOS;
- diagnóstico o recomendaciones automatizadas;
- publicación en App Store;
- onboarding comercial de múltiples clínicas;
- cobro de suscripciones;
- mensajería RabbitMQ y microservicios.

## 7. Decisión multiclínica

La base ya representa `clinica`, `sede` y `usuario_clinica`, y el login devuelve un contexto de clínica. Esto prepara la evolución del producto sin afirmar un aislamiento multitenant completo. El piloto opera con una clínica y una sede demostrativas. Antes de incorporar nuevos clientes deberán completarse administración de tenants, selección de clínica, aislamiento probado, políticas de retención y observabilidad por tenant.

## 8. Restricciones

- Equipo de dos integrantes y calendario académico reducido.
- Cliente iOS basado en UIKit, Storyboard, outlets, actions y segues.
- Compilación iOS disponible únicamente en macOS/Xcode.
- Servicio Render gratuito sujeto a arranque en frío.
- Uso exclusivo de datos ficticios durante el piloto académico.

## 9. Criterio de éxito del Release 0.1

El release es exitoso cuando un paciente demo puede completar el recorrido principal contra la API desplegada, la app conserva una lectura offline de sus citas, la reserva no admite solapamientos, los recursos solo son accesibles por su propietario y la compilación final no presenta errores ni advertencias de Storyboard.
