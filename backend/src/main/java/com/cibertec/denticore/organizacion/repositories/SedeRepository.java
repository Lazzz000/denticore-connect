package com.cibertec.denticore.organizacion.repositories;

import com.cibertec.denticore.organizacion.entities.Sede;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SedeRepository extends JpaRepository<Sede, Integer> {
    List<Sede> findByClinicaIdAndActivoTrueOrderByNombreAsc(Integer clinicaId);
    Optional<Sede> findFirstByClinicaIdAndActivoTrueOrderByIdAsc(Integer clinicaId);
}
