package com.cibertec.denticore.security.entities;

import com.cibertec.denticore.organizacion.entities.Clinica;
import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.time.OffsetDateTime;

@Entity
@Table(name = "usuario_clinica", schema = "seguridad")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UsuarioClinica {

    @EmbeddedId
    private UsuarioClinicaId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idUsuario")
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idClinica")
    @JoinColumn(name = "id_clinica", nullable = false)
    private Clinica clinica;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idRol")
    @JoinColumn(name = "id_rol", nullable = false)
    private Rol rol;

    @Column(nullable = false)
    private Boolean activo;

    @Column(name = "fecha_creacion", nullable = false)
    private OffsetDateTime fechaCreacion;

    @Embeddable
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class UsuarioClinicaId implements Serializable {
        @Column(name = "id_usuario")
        private Integer idUsuario;

        @Column(name = "id_clinica")
        private Integer idClinica;

        @Column(name = "id_rol")
        private Integer idRol;
    }
}
