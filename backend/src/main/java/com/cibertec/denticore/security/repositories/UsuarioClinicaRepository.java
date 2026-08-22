package com.cibertec.denticore.security.repositories;

import com.cibertec.denticore.security.entities.UsuarioClinica;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UsuarioClinicaRepository
        extends JpaRepository<UsuarioClinica, UsuarioClinica.UsuarioClinicaId> {

    @Query("""
        SELECT uc FROM UsuarioClinica uc
        JOIN FETCH uc.clinica c
        JOIN FETCH uc.rol r
        WHERE uc.usuario.id = :usuarioId
          AND uc.activo = true
          AND c.activo = true
        ORDER BY c.id ASC
        """)
    List<UsuarioClinica> findMembresiasActivas(@Param("usuarioId") Integer usuarioId);
}
