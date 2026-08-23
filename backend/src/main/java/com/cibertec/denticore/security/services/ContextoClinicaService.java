package com.cibertec.denticore.security.services;

import com.cibertec.denticore.security.dto.response.ContextoClinicaDTO;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.repositories.UsuarioClinicaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import com.cibertec.denticore.common.ApiException;

@Service
@RequiredArgsConstructor
public class ContextoClinicaService {

    private final UsuarioClinicaRepository usuarioClinicaRepository;

    @Transactional(readOnly = true)
    public UsuarioClinica obtenerMembresiaPrincipal(Integer usuarioId) {
        return usuarioClinicaRepository.findMembresiasActivas(usuarioId).stream()
                .findFirst()
                .orElseThrow(() -> new ApiException(
                        HttpStatus.FORBIDDEN,
                        "CLINIC_CONTEXT_NOT_AVAILABLE",
                        "El usuario no tiene una clínica activa asignada."));
    }

    public ContextoClinicaDTO mapearContexto(UsuarioClinica membresia) {
        return new ContextoClinicaDTO(
                membresia.getClinica().getId(),
                membresia.getClinica().getNombreComercial(),
                membresia.getClinica().getZonaHoraria());
    }
}
