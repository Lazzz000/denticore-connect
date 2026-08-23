package com.cibertec.denticore.security.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class RegistroPacienteRequestDTO {

    @NotBlank
    @Pattern(regexp = "\\d{8}")
    private String dni;

    @NotBlank
    @Size(min = 2, max = 80)
    private String nombres;

    @NotBlank
    @Size(min = 2, max = 100)
    private String apellidos;

    @NotBlank
    @Email
    @Size(max = 120)
    private String correo;

    @NotBlank
    @Size(min = 8, max = 72)
    private String password;

    private String grupoSanguineo;

    @NotNull
    @Past
    private LocalDate fechaNacimiento;
}
