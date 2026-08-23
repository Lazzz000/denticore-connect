package com.cibertec.denticore.agenda.repositories;

import com.cibertec.denticore.agenda.entities.HorarioOdontologo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface HorarioOdontologoRepository extends JpaRepository<HorarioOdontologo, Integer> {

    @Query("""
        SELECT h FROM HorarioOdontologo h
        WHERE h.odontologo.idUsuario = :odontologoId
          AND h.sede.id = :sedeId
          AND h.diaSemana = :diaSemana
          AND h.activo = true
          AND h.vigenciaDesde <= :fecha
          AND (h.vigenciaHasta IS NULL OR h.vigenciaHasta >= :fecha)
        ORDER BY h.horaInicio ASC
        """)
    List<HorarioOdontologo> findVigentes(
            @Param("odontologoId") Integer odontologoId,
            @Param("sedeId") Integer sedeId,
            @Param("diaSemana") Short diaSemana,
            @Param("fecha") LocalDate fecha);
}
