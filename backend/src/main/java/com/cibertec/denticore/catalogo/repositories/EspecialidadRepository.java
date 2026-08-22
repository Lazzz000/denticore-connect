package com.cibertec.denticore.catalogo.repositories;

import com.cibertec.denticore.catalogo.entities.Especialidad;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EspecialidadRepository extends JpaRepository<Especialidad, Integer> {

    List<Especialidad> findByActivoTrue();
    List<Especialidad> findByActivoTrueOrderByNombreAsc();
}
