package com.cibertec.denticore.security.repositories;

import com.cibertec.denticore.security.entities.Odontologo;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OdontologoRepository extends JpaRepository<Odontologo, Integer> {

    Optional<Odontologo> findByUsuarioDni(String dni);

}
