package com.cibertec.denticore.common;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.OffsetDateTime;

@Data
@AllArgsConstructor
public class ApiErrorDTO {
    private OffsetDateTime timestamp;
    private int status;
    private String code;
    private String message;
    private String path;
    private String traceId;
}
