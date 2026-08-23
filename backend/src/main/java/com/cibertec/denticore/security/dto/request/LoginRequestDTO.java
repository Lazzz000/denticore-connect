package com.cibertec.denticore.security.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LoginRequestDTO {

    @NotBlank
    @Pattern(regexp = "\\d{8}")
    private String dni;

    @NotBlank
    @Size(min = 8, max = 72)
    private String password;
}
