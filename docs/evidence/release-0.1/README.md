# Evidencias del Release 0.1

Esta carpeta registra los reportes y huellas de integridad asociados con [EVIDENCE_REGISTER.md](../../EVIDENCE_REGISTER.md). Las capturas se conservan en el expediente privado de sustentación y no se publican en GitHub.

## Reglas

- Usar nombres `EV-XX_descripcion_YYYYMMDD.ext`.
- Recortar barras, ventanas o datos que no aporten a la prueba.
- No incluir contraseñas, JWT, secretos, correo privado o DNI completo.
- Cada archivo debe corresponder a una fila del registro maestro.
- Conservar preferentemente PNG para capturas, TXT para logs y PDF para reportes exportados.
- Generar una huella SHA-256 por cada archivo aceptado y registrarla en `EVIDENCE_MANIFEST.sha256`.

No declarar una evidencia como conforme si el archivo todavía no existe.

## Evidencias incorporadas

- EV-03: despliegue y health `UP`.
- EV-04: compilación iOS satisfactoria.
- EV-06: inicio con paciente y clínica.
- EV-07: navegación principal mediante tab bar.
- EV-08: especialidades y servicios consumidos desde la API.
- EV-09: selección de odontólogo y horario.
- EV-10: confirmación de creación de cita.
- EV-11: listado, historial y detalle.
- EV-12: confirmación de cancelación y estado resultante.
- EV-15: recordatorios habilitados y permiso concedido en iOS.

EV-05 y EV-13 requieren nuevas capturas sin datos sensibles. EV-18 debe recapturarse después de comprobar en Xcode que el ajuste de Auto Layout eliminó las dos advertencias de ambigüedad vertical.
