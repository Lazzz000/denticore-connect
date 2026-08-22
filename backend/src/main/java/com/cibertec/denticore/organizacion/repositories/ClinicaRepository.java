package com.cibertec.denticore.organizacion.repositories;

import com.cibertec.denticore.organizacion.entities.Clinica;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClinicaRepository extends JpaRepository<Clinica, Integer> {
    Optional<Clinica> findByCodigoAndActivoTrue(String codigo);
}
