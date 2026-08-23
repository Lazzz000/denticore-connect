package com.cibertec.denticore.movil.services;

import com.cibertec.denticore.movil.dto.PerfilPacienteDTO;
import com.cibertec.denticore.movil.dto.SedeDTO;
import com.cibertec.denticore.organizacion.repositories.SedeRepository;
import com.cibertec.denticore.security.entities.Paciente;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.repositories.PacienteRepository;
import com.cibertec.denticore.security.services.ContextoClinicaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PacienteMovilService {

    private final PacienteRepository pacienteRepository;
    private final SedeRepository sedeRepository;
    private final ContextoClinicaService contextoClinicaService;

    @Transactional(readOnly = true)
    public PerfilPacienteDTO obtenerPerfil(String dni) {
        Paciente paciente = pacienteRepository.findByUsuarioDni(dni)
                .orElseThrow(() -> new IllegalStateException("Paciente autenticado no encontrado"));
        UsuarioClinica membresia = contextoClinicaService
                .obtenerMembresiaPrincipal(paciente.getIdUsuario());

        return new PerfilPacienteDTO(
                paciente.getIdUsuario(),
                paciente.getUsuario().getDni(),
                paciente.getUsuario().getNombres(),
                paciente.getUsuario().getApellidos(),
                paciente.getUsuario().getCorreo(),
                paciente.getFechaNacimiento(),
                contextoClinicaService.mapearContexto(membresia));
    }

    @Transactional(readOnly = true)
    public List<SedeDTO> listarSedes(String dni) {
        Paciente paciente = pacienteRepository.findByUsuarioDni(dni)
                .orElseThrow(() -> new IllegalStateException("Paciente autenticado no encontrado"));
        UsuarioClinica membresia = contextoClinicaService
                .obtenerMembresiaPrincipal(paciente.getIdUsuario());

        return sedeRepository
                .findByClinicaIdAndActivoTrueOrderByNombreAsc(membresia.getClinica().getId())
                .stream()
                .map(sede -> new SedeDTO(
                        sede.getId(),
                        sede.getNombre(),
                        sede.getDireccion(),
                        sede.getClinica().getZonaHoraria(),
                        sede.getActivo()))
                .toList();
    }
}
