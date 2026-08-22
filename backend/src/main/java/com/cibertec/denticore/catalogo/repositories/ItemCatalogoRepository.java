package com.cibertec.denticore.catalogo.repositories;

import com.cibertec.denticore.catalogo.entities.ItemCatalogo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ItemCatalogoRepository extends JpaRepository<ItemCatalogo, Integer> {
    // Método autogenerado para listar ítems por su estado (activo o inactivo)
    List<ItemCatalogo> findByActivoTrue();
    List<ItemCatalogo> findByActivoTrueAndTipoOrderByNombreAsc(String tipo);
    List<ItemCatalogo> findByActivoTrueAndTipoAndEspecialidadIdOrderByNombreAsc(
            String tipo, Integer especialidadId);
    Optional<ItemCatalogo> findByCodigoAndActivoTrue(String codigo);
}
