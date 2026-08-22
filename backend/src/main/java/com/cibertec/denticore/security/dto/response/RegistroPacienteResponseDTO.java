package com.cibertec.denticore.security.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegistroPacienteResponseDTO {
    private Integer id;
    private String dni;
    private String nombres;
    private String apellidos;
    private String correo;
    private Integer clinicaId;
    private String estado;
}
