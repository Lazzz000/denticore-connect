package com.cibertec.denticore.movil.dto;

import jakarta.validation.constraints.Size;

public record CancelarCitaPacienteRequestDTO(
        @Size(max = 300, message = "El motivo no puede superar los 300 caracteres.")
        String motivo) {
}
