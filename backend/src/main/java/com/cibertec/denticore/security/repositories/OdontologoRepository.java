package com.cibertec.denticore.security.repositories;

import com.cibertec.denticore.security.entities.Odontologo;

import java.util.Optional;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface OdontologoRepository extends JpaRepository<Odontologo, Integer> {

    Optional<Odontologo> findByUsuarioDni(String dni);

    @Query(value = """
        SELECT DISTINCT o.*
        FROM seguridad.odontologo o
        JOIN seguridad.usuario u ON u.id = o.id_usuario
        JOIN catalogo.odontologo_especialidad oe
          ON oe.id_odontologo = o.id_usuario
        JOIN seguridad.usuario_clinica uc
          ON uc.id_usuario = o.id_usuario
        WHERE o.activo = TRUE
          AND u.activo = TRUE
          AND oe.id_especialidad = :especialidadId
          AND uc.id_clinica = :clinicaId
          AND uc.activo = TRUE
        ORDER BY u.apellidos ASC, u.nombres ASC
        """, nativeQuery = true)
    List<Odontologo> findActivosByClinicaAndEspecialidad(
            @Param("clinicaId") Integer clinicaId,
            @Param("especialidadId") Integer especialidadId);
}
