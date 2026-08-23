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

    @Query("""
        SELECT o FROM Odontologo o
        JOIN FETCH o.usuario u
        WHERE o.activo = true
          AND u.activo = true
          AND EXISTS (
              SELECT oe.id FROM OdontologoEspecialidad oe
              WHERE oe.odontologo = o
                AND oe.especialidad.id = :especialidadId
          )
          AND EXISTS (
              SELECT uc.id FROM UsuarioClinica uc
              WHERE uc.usuario = u
                AND uc.clinica.id = :clinicaId
                AND uc.activo = true
          )
        ORDER BY u.apellidos ASC, u.nombres ASC
        """)
    List<Odontologo> findActivosByClinicaAndEspecialidad(
            @Param("clinicaId") Integer clinicaId,
            @Param("especialidadId") Integer especialidadId);
}
