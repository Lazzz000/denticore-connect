package com.cibertec.denticore.agenda.repositories;

import com.cibertec.denticore.agenda.entities.BloqueoHorario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.OffsetDateTime;
import java.util.List;

public interface BloqueoHorarioRepository extends JpaRepository<BloqueoHorario, Integer> {

    @Query("""
        SELECT b FROM BloqueoHorario b
        WHERE b.odontologo.idUsuario = :odontologoId
          AND b.sede.id = :sedeId
          AND b.activo = true
          AND b.fechaHoraInicio < :fin
          AND b.fechaHoraFin > :inicio
        """)
    List<BloqueoHorario> findActivosEnRango(
            @Param("odontologoId") Integer odontologoId,
            @Param("sedeId") Integer sedeId,
            @Param("inicio") OffsetDateTime inicio,
            @Param("fin") OffsetDateTime fin);
}
