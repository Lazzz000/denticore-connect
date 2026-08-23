package com.cibertec.denticore.movil.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.OffsetDateTime;

public record CrearCitaPacienteRequestDTO(
        @NotNull Integer idOdontologo,
        @NotNull Integer idServicio,
        @NotNull @Future OffsetDateTime fechaHora,
        @Size(max = 300) String notaPaciente) {
}
