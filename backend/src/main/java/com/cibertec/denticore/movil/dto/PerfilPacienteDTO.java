package com.cibertec.denticore.movil.dto;

import com.cibertec.denticore.security.dto.response.ContextoClinicaDTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PerfilPacienteDTO {
    private Integer id;
    private String dni;
    private String nombres;
    private String apellidos;
    private String correo;
    private LocalDate fechaNacimiento;
    private ContextoClinicaDTO clinica;
}
