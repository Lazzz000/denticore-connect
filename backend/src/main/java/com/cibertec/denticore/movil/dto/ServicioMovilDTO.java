package com.cibertec.denticore.movil.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ServicioMovilDTO {
    private Integer id;
    private String codigo;
    private String nombre;
    private Integer especialidadId;
    private Integer duracionMinutos;
    private BigDecimal costoReferencial;
    private String moneda;
    private Boolean activo;
}
