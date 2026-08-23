package com.cibertec.denticore.movil.services;

import com.cibertec.denticore.catalogo.entities.ItemCatalogo;
import com.cibertec.denticore.catalogo.repositories.EspecialidadRepository;
import com.cibertec.denticore.catalogo.repositories.ItemCatalogoRepository;
import com.cibertec.denticore.movil.dto.EspecialidadMovilDTO;
import com.cibertec.denticore.movil.dto.ServicioMovilDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CatalogoMovilService {

    private final EspecialidadRepository especialidadRepository;
    private final ItemCatalogoRepository itemCatalogoRepository;

    @Transactional(readOnly = true)
    public List<EspecialidadMovilDTO> listarEspecialidades() {
        return especialidadRepository.findByActivoTrueOrderByNombreAsc().stream()
                .map(item -> new EspecialidadMovilDTO(item.getId(), item.getNombre()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ServicioMovilDTO> listarServicios(Integer especialidadId) {
        List<ItemCatalogo> servicios = especialidadId == null
                ? itemCatalogoRepository.findByActivoTrueAndTipoOrderByNombreAsc("Servicio")
                : itemCatalogoRepository
                    .findByActivoTrueAndTipoAndEspecialidadIdOrderByNombreAsc(
                            "Servicio", especialidadId);

        return servicios.stream().map(item -> new ServicioMovilDTO(
                item.getId(),
                item.getCodigo(),
                item.getNombre(),
                item.getEspecialidad() == null ? null : item.getEspecialidad().getId(),
                item.getDuracionMinutos(),
                item.getCostoReferencial(),
                "PEN",
                item.getActivo())).toList();
    }
}
