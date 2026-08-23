package com.cibertec.denticore.movil.controllers;

import com.cibertec.denticore.movil.dto.EspecialidadMovilDTO;
import com.cibertec.denticore.movil.dto.ServicioMovilDTO;
import com.cibertec.denticore.movil.services.CatalogoMovilService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('PACIENTE', 'ADMINISTRADOR', 'ODONTOLOGO')")
public class CatalogoMovilController {

    private final CatalogoMovilService catalogoMovilService;

    @GetMapping("/especialidades")
    public ResponseEntity<List<EspecialidadMovilDTO>> listarEspecialidades() {
        return ResponseEntity.ok(catalogoMovilService.listarEspecialidades());
    }

    @GetMapping("/servicios")
    public ResponseEntity<List<ServicioMovilDTO>> listarServicios(
            @RequestParam(required = false) Integer especialidadId) {
        return ResponseEntity.ok(catalogoMovilService.listarServicios(especialidadId));
    }
}
