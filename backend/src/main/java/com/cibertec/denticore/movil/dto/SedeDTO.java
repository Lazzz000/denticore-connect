package com.cibertec.denticore.movil.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SedeDTO {
    private Integer id;
    private String nombre;
    private String direccion;
    private String zonaHoraria;
    private Boolean activa;
}
