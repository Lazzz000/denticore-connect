package com.cibertec.denticore.movil.dto;

import java.time.OffsetDateTime;

public record HorarioDisponibleDTO(
        OffsetDateTime fechaHoraInicio,
        OffsetDateTime fechaHoraFin) {
}
