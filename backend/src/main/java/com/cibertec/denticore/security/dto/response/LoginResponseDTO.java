package com.cibertec.denticore.security.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponseDTO {
    private String accessToken;
    private String tokenType;
    private Long expiresIn;
    private String rol;
    private ContextoClinicaDTO contextoClinica;
}
