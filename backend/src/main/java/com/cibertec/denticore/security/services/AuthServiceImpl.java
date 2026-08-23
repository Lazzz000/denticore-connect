package com.cibertec.denticore.security.services;

import com.cibertec.denticore.clinica.entities.HistoriaClinica;
import com.cibertec.denticore.clinica.repositories.HistoriaClinicaRepository;
import com.cibertec.denticore.security.dto.request.RegistroPacienteRequestDTO;
import com.cibertec.denticore.security.dto.response.RegistroPacienteResponseDTO;
import com.cibertec.denticore.security.entities.Paciente;
import com.cibertec.denticore.security.entities.Rol;
import com.cibertec.denticore.security.entities.Usuario;
import com.cibertec.denticore.security.entities.UsuarioRol;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.repositories.PacienteRepository;
import com.cibertec.denticore.security.repositories.RolRepository;
import com.cibertec.denticore.security.repositories.UsuarioRepository;
import com.cibertec.denticore.security.repositories.UsuarioRolRepository;
import com.cibertec.denticore.security.repositories.UsuarioClinicaRepository;
import com.cibertec.denticore.organizacion.entities.Clinica;
import com.cibertec.denticore.organizacion.repositories.ClinicaRepository;
import com.cibertec.denticore.common.ApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;

import java.time.OffsetDateTime;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final UsuarioRolRepository usuarioRolRepository;
    private final PacienteRepository pacienteRepository;
    private final HistoriaClinicaRepository historiaClinicaRepository;
    private final ClinicaRepository clinicaRepository;
    private final UsuarioClinicaRepository usuarioClinicaRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public RegistroPacienteResponseDTO registrarPaciente(RegistroPacienteRequestDTO dto) {
        if (usuarioRepository.findByDni(dto.getDni()).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "PATIENT_ALREADY_EXISTS",
                    "Ya existe un paciente con el DNI o correo indicado.");
        }
        if (usuarioRepository.existsByCorreoIgnoreCase(dto.getCorreo())) {
            throw new ApiException(HttpStatus.CONFLICT, "PATIENT_ALREADY_EXISTS",
                    "Ya existe un paciente con el DNI o correo indicado.");
        }

        Usuario usuario = new Usuario();
        usuario.setNombreUsuario(dto.getDni());
        usuario.setDni(dto.getDni());
        usuario.setNombres(dto.getNombres());
        usuario.setApellidos(dto.getApellidos());
        usuario.setCorreo(dto.getCorreo());
        usuario.setTipoDocumentoSunat("1");
        usuario.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        usuario.setActivo(true);

        Usuario usuarioGuardado = usuarioRepository.save(usuario);

        Rol rolPaciente = rolRepository.findByNombre("PACIENTE")
                .orElseThrow(() -> new RuntimeException("Rol PACIENTE no encontrado"));

        UsuarioRol.UsuarioRolId usuarioRolId = new UsuarioRol.UsuarioRolId();
        usuarioRolId.setIdUsuario(usuarioGuardado.getId());
        usuarioRolId.setIdRol(rolPaciente.getId());

        UsuarioRol usuarioRol = new UsuarioRol();
        usuarioRol.setId(usuarioRolId);
        usuarioRol.setUsuario(usuarioGuardado);
        usuarioRol.setRol(rolPaciente);
        usuarioRol.setActivo(true);

        usuarioRolRepository.save(usuarioRol);

        Paciente paciente = new Paciente();
        paciente.setUsuario(usuarioGuardado);
        paciente.setGrupoSanguineo(dto.getGrupoSanguineo());
        paciente.setFechaNacimiento(dto.getFechaNacimiento());
        paciente.setActivo(true);

        Paciente pacienteGuardado = pacienteRepository.save(paciente);

        HistoriaClinica historiaClinica = new HistoriaClinica();
        historiaClinica.setPaciente(pacienteGuardado);
        historiaClinica.setCodigoHistorial("HC-" + dto.getDni());
        historiaClinica.setCreadoPor(usuarioGuardado);

        historiaClinicaRepository.save(historiaClinica);

        Clinica clinica = clinicaRepository.findByCodigoAndActivoTrue("PILOTO-001")
                .orElseThrow(() -> new IllegalStateException("Clínica piloto no configurada"));

        UsuarioClinica.UsuarioClinicaId membresiaId = new UsuarioClinica.UsuarioClinicaId(
                usuarioGuardado.getId(), clinica.getId(), rolPaciente.getId());

        usuarioClinicaRepository.save(UsuarioClinica.builder()
                .id(membresiaId)
                .usuario(usuarioGuardado)
                .clinica(clinica)
                .rol(rolPaciente)
                .activo(true)
                .fechaCreacion(OffsetDateTime.now())
                .build());

        return new RegistroPacienteResponseDTO(
                usuarioGuardado.getId(),
                usuarioGuardado.getDni(),
                usuarioGuardado.getNombres(),
                usuarioGuardado.getApellidos(),
                usuarioGuardado.getCorreo(),
                clinica.getId(),
                "ACTIVO");
    }
}
