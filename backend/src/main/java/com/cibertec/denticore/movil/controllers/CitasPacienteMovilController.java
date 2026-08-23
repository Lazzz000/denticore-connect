package com.cibertec.denticore.movil.controllers;

import com.cibertec.denticore.movil.dto.CitaPacienteDTO;
import com.cibertec.denticore.movil.dto.CrearCitaPacienteRequestDTO;
import com.cibertec.denticore.movil.dto.HorarioDisponibleDTO;
import com.cibertec.denticore.movil.dto.OdontologoMovilDTO;
import com.cibertec.denticore.movil.services.CitasPacienteMovilService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/pacientes/me")
@RequiredArgsConstructor
@PreAuthorize("hasRole('PACIENTE')")
public class CitasPacienteMovilController {

    private final CitasPacienteMovilService citasService;

    @GetMapping("/odontologos")
    public ResponseEntity<List<OdontologoMovilDTO>> listarOdontologos(
            Principal principal,
            @RequestParam Integer especialidadId) {
        return ResponseEntity.ok(citasService.listarOdontologos(
                principal.getName(), especialidadId));
    }

    @GetMapping("/disponibilidad")
    public ResponseEntity<List<HorarioDisponibleDTO>> listarDisponibilidad(
            Principal principal,
            @RequestParam Integer odontologoId,
            @RequestParam Integer servicioId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
        return ResponseEntity.ok(citasService.listarDisponibilidad(
                principal.getName(), odontologoId, servicioId, fecha));
    }

    @GetMapping("/citas")
    public ResponseEntity<List<CitaPacienteDTO>> listarCitas(
            Principal principal) {
        return ResponseEntity.ok(citasService.listarCitas(principal.getName()));
    }

    @PostMapping("/citas")
    public ResponseEntity<CitaPacienteDTO> crearCita(
            Principal principal,
            @Valid @RequestBody CrearCitaPacienteRequestDTO request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(
                citasService.crearCita(principal.getName(), request));
    }
}
