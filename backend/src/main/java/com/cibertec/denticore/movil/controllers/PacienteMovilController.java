package com.cibertec.denticore.movil.controllers;

import com.cibertec.denticore.movil.dto.PerfilPacienteDTO;
import com.cibertec.denticore.movil.dto.SedeDTO;
import com.cibertec.denticore.movil.services.PacienteMovilService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.List;

@RestController
@RequiredArgsConstructor
@PreAuthorize("hasRole('PACIENTE')")
public class PacienteMovilController {

    private final PacienteMovilService pacienteMovilService;

    @GetMapping("/pacientes/me")
    public ResponseEntity<PerfilPacienteDTO> obtenerMiPerfil(Principal principal) {
        return ResponseEntity.ok(pacienteMovilService.obtenerPerfil(principal.getName()));
    }

    @GetMapping("/sedes")
    public ResponseEntity<List<SedeDTO>> listarSedes(Principal principal) {
        return ResponseEntity.ok(pacienteMovilService.listarSedes(principal.getName()));
    }
}
