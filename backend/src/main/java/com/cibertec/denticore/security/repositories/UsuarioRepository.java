package com.cibertec.denticore.security.repositories;

import com.cibertec.denticore.security.entities.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {
    // Spring Data genera automáticamente el SQL basado en el nombre del método
    Optional<Usuario> findByDni(String dni);
    Optional<Usuario> findByNombreUsuario(String nombreUsuario);
    boolean existsByCorreoIgnoreCase(String correo);
}
