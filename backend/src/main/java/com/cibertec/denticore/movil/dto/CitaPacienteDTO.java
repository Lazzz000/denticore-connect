package com.cibertec.denticore.movil.dto;

import java.time.OffsetDateTime;

public record CitaPacienteDTO(
        Integer id,
        String estado,
        OffsetDateTime fechaHora,
        OffsetDateTime fechaHoraFin,
        String odontologoNombre,
        String servicioNombre,
        String especialidadNombre,
        String sedeNombre,
        String notaPaciente,
        String mensaje) {
}
