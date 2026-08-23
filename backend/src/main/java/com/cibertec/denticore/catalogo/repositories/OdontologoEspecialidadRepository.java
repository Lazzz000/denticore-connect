package com.cibertec.denticore.catalogo.repositories;

import com.cibertec.denticore.catalogo.entities.OdontologoEspecialidad;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OdontologoEspecialidadRepository extends JpaRepository<OdontologoEspecialidad, OdontologoEspecialidad.OdontologoEspecialidadId> {
    boolean existsById_IdOdontologoAndId_IdEspecialidad(
            Integer odontologoId, Integer especialidadId);
}
