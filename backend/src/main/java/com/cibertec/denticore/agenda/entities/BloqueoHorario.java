package com.cibertec.denticore.agenda.entities;

import com.cibertec.denticore.organizacion.entities.Sede;
import com.cibertec.denticore.security.entities.Odontologo;
import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;

@Entity
@Table(name = "bloqueo_horario", schema = "agenda")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BloqueoHorario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_odontologo", nullable = false)
    private Odontologo odontologo;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_sede", nullable = false)
    private Sede sede;

    @Column(name = "fecha_hora_inicio", nullable = false)
    private OffsetDateTime fechaHoraInicio;

    @Column(name = "fecha_hora_fin", nullable = false)
    private OffsetDateTime fechaHoraFin;

    @Column(length = 200)
    private String motivo;

    @Column(nullable = false)
    private Boolean activo;
}
