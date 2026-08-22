package com.cibertec.denticore.security.config;

import com.cibertec.denticore.clinica.entities.HistoriaClinica;
import com.cibertec.denticore.clinica.repositories.HistoriaClinicaRepository;
import com.cibertec.denticore.organizacion.entities.Clinica;
import com.cibertec.denticore.organizacion.repositories.ClinicaRepository;
import com.cibertec.denticore.security.entities.Paciente;
import com.cibertec.denticore.security.entities.Rol;
import com.cibertec.denticore.security.entities.Usuario;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.entities.UsuarioRol;
import com.cibertec.denticore.security.repositories.PacienteRepository;
import com.cibertec.denticore.security.repositories.RolRepository;
import com.cibertec.denticore.security.repositories.UsuarioClinicaRepository;
import com.cibertec.denticore.security.repositories.UsuarioRepository;
import com.cibertec.denticore.security.repositories.UsuarioRolRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;

@Slf4j
@Service
@Profile("demo")
@RequiredArgsConstructor
public class DemoPatientBootstrapService {

    private static final String PILOT_CLINIC_CODE = "PILOTO-001";

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final UsuarioRolRepository usuarioRolRepository;
    private final PacienteRepository pacienteRepository;
    private final ClinicaRepository clinicaRepository;
    private final UsuarioClinicaRepository usuarioClinicaRepository;
    private final HistoriaClinicaRepository historiaClinicaRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void createPatientIfMissing(String dni, String email, String password) {
        validateConfiguration(dni, email, password);

        Usuario existingUser = usuarioRepository.findByDni(dni).orElse(null);
        if (existingUser != null) {
            existingUser.setCorreo(email);
            existingUser.setPasswordHash(passwordEncoder.encode(password));
            existingUser.setActivo(true);
            usuarioRepository.save(existingUser);
            log.info("Se sincronizaron de forma segura las credenciales del paciente demo.");
            return;
        }

        Rol patientRole = rolRepository.findByNombre("PACIENTE")
                .orElseGet(() -> rolRepository.save(Rol.builder()
                        .nombre("PACIENTE")
                        .activo(true)
                        .build()));
        Clinica clinic = clinicaRepository.findByCodigoAndActivoTrue(PILOT_CLINIC_CODE)
                .orElseThrow(() -> new IllegalStateException("No existe la clínica piloto migrada."));

        Usuario user = usuarioRepository.save(Usuario.builder()
                .nombreUsuario("paciente_" + dni)
                .dni(dni)
                .tipoDocumentoSunat("1")
                .nombres("Paciente")
                .apellidos("Demostración")
                .direccionFiscal("Lima")
                .correo(email)
                .passwordHash(passwordEncoder.encode(password))
                .activo(true)
                .build());

        usuarioRolRepository.save(UsuarioRol.builder()
                .id(new UsuarioRol.UsuarioRolId(user.getId(), patientRole.getId()))
                .usuario(user)
                .rol(patientRole)
                .activo(true)
                .build());

        Paciente patient = pacienteRepository.save(Paciente.builder()
                .usuario(user)
                .grupoSanguineo("O+")
                .alergias("Ninguna declarada")
                .fechaNacimiento(LocalDate.of(1995, 1, 1))
                .activo(true)
                .build());

        usuarioClinicaRepository.save(UsuarioClinica.builder()
                .id(new UsuarioClinica.UsuarioClinicaId(user.getId(), clinic.getId(), patientRole.getId()))
                .usuario(user)
                .clinica(clinic)
                .rol(patientRole)
                .activo(true)
                .fechaCreacion(OffsetDateTime.now())
                .build());

        historiaClinicaRepository.save(HistoriaClinica.builder()
                .paciente(patient)
                .codigoHistorial("HC-DEMO-" + user.getId())
                .creadoPor(user)
                .fechaCreacion(LocalDateTime.now())
                .build());

        log.info("Paciente demo creado para la clínica piloto.");
    }

    private void validateConfiguration(String dni, String email, String password) {
        if (!dni.matches("\\d{8}")) {
            throw new IllegalStateException("DEMO_PATIENT_DNI debe contener exactamente 8 dígitos.");
        }
        if (!email.contains("@")) {
            throw new IllegalStateException("DEMO_PATIENT_EMAIL no tiene un formato válido.");
        }
        if (password.length() < 8) {
            throw new IllegalStateException("DEMO_PATIENT_PASSWORD debe tener al menos 8 caracteres.");
        }
    }
}
