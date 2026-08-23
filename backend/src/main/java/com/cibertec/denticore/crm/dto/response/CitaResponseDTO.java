package com.cibertec.denticore.crm.dto.response;

import lombok.Data;
import java.time.OffsetDateTime;

@Data
public class CitaResponseDTO {

    private Integer id;
    private String estado;
    private OffsetDateTime fechaHora;
    private String mensaje;
}
