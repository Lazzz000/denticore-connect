package com.cibertec.denticore.crm.entities;

import com.cibertec.denticore.crm.enums.EstadoCita;
import com.cibertec.denticore.security.entities.Odontologo;
import com.cibertec.denticore.security.entities.Paciente;
import com.cibertec.denticore.security.entities.Usuario;
import com.cibertec.denticore.catalogo.entities.ItemCatalogo;
import com.cibertec.denticore.organizacion.entities.Clinica;
import com.cibertec.denticore.organizacion.entities.Sede;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "cita", schema = "crm")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Cita {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_paciente", nullable = false)
    private Paciente paciente;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_odontologo", nullable = false)
    private Odontologo odontologo;

    @Column(name = "fecha_hora", nullable = false)
    private OffsetDateTime fechaHora;

    @Column(name = "fecha_hora_fin", nullable = false)
    private OffsetDateTime fechaHoraFin;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EstadoCita estado;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_lead_contacto")
    private LeadContacto leadContacto;

    @Column(name = "canal_origen", nullable = false, length = 50)
    private String canalOrigen;

    @Column(name = "monto_adelanto", nullable = false, precision = 10, scale = 2)
    private BigDecimal montoAdelanto = BigDecimal.ZERO;

    @Column(name = "referencia_adelanto", length = 100)
    private String referenciaAdelanto;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_clinica", nullable = false)
    private Clinica clinica;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_sede", nullable = false)
    private Sede sede;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_servicio", nullable = false)
    private ItemCatalogo servicio;

    @Column(name = "nota_paciente", length = 300)
    private String notaPaciente;

    @Column(name = "motivo_cancelacion", length = 300)
    private String motivoCancelacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cancelada_por")
    private Usuario canceladaPor;

    @Column(name = "fecha_cancelacion")
    private OffsetDateTime fechaCancelacion;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "creado_por", nullable = false)
    private Usuario creadoPor;

    @Builder.Default
    @Column(name = "fecha_creacion", nullable = false, updatable = false)
    private OffsetDateTime fechaCreacion = OffsetDateTime.now();

    @Column(name = "fecha_modificacion")
    private OffsetDateTime fechaModificacion;

    @Version
    @Column(nullable = false)
    private Long version;
}
