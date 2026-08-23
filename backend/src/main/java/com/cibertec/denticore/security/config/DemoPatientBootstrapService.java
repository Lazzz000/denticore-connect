package com.cibertec.denticore.security.config;

import com.cibertec.denticore.clinica.entities.HistoriaClinica;
import com.cibertec.denticore.clinica.repositories.HistoriaClinicaRepository;
import com.cibertec.denticore.catalogo.entities.ItemCatalogo;
import com.cibertec.denticore.catalogo.repositories.ItemCatalogoRepository;
import com.cibertec.denticore.crm.entities.Cita;
import com.cibertec.denticore.crm.enums.EstadoCita;
import com.cibertec.denticore.crm.repositories.CitaRepository;
import com.cibertec.denticore.organizacion.entities.Clinica;
import com.cibertec.denticore.organizacion.entities.Sede;
import com.cibertec.denticore.organizacion.repositories.ClinicaRepository;
import com.cibertec.denticore.organizacion.repositories.SedeRepository;
import com.cibertec.denticore.security.entities.Odontologo;
import com.cibertec.denticore.security.entities.Paciente;
import com.cibertec.denticore.security.entities.Rol;
import com.cibertec.denticore.security.entities.Usuario;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.entities.UsuarioRol;
import com.cibertec.denticore.security.repositories.PacienteRepository;
import com.cibertec.denticore.security.repositories.OdontologoRepository;
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

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;

@Slf4j
@Service
@Profile("demo")
@RequiredArgsConstructor
public class DemoPatientBootstrapService {

    private static final String PILOT_CLINIC_CODE = "PILOTO-001";
    private static final String DEMO_DENTIST_DNI = "73000001";
    private static final String DEMO_SERVICE_CODE = "GEN-EVAL";
    private static final String DEMO_APPOINTMENT_CHANNEL = "DEMO_SEED";

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final UsuarioRolRepository usuarioRolRepository;
    private final PacienteRepository pacienteRepository;
    private final ClinicaRepository clinicaRepository;
    private final UsuarioClinicaRepository usuarioClinicaRepository;
    private final HistoriaClinicaRepository historiaClinicaRepository;
    private final OdontologoRepository odontologoRepository;
    private final ItemCatalogoRepository itemCatalogoRepository;
    private final SedeRepository sedeRepository;
    private final CitaRepository citaRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void synchronizeDemoPatient(
            String dni,
            String email,
            String password,
            String names,
            String surnames) {
        validateConfiguration(dni, email, password, names, surnames);

        Clinica clinic = clinicaRepository.findByCodigoAndActivoTrue(PILOT_CLINIC_CODE)
                .orElseThrow(() -> new IllegalStateException("No existe la clínica piloto migrada."));

        Usuario existingUser = usuarioRepository.findByDni(dni).orElse(null);
        if (existingUser != null) {
            existingUser.setNombres(names);
            existingUser.setApellidos(surnames);
            existingUser.setCorreo(email);
            existingUser.setPasswordHash(passwordEncoder.encode(password));
            existingUser.setActivo(true);
            usuarioRepository.save(existingUser);

            Paciente existingPatient = pacienteRepository.findById(existingUser.getId())
                    .orElseThrow(() -> new IllegalStateException(
                            "El usuario demo existe, pero no posee perfil de paciente."));
            ensureAttendedAppointment(existingPatient, clinic);
            log.info("Se sincronizaron de forma segura el perfil y las credenciales del paciente demo.");
            return;
        }

        Rol patientRole = rolRepository.findByNombre("PACIENTE")
                .orElseGet(() -> rolRepository.save(Rol.builder()
                        .nombre("PACIENTE")
                        .activo(true)
                        .build()));
        Usuario user = usuarioRepository.save(Usuario.builder()
                .nombreUsuario("paciente_" + dni)
                .dni(dni)
                .tipoDocumentoSunat("1")
                .nombres(names)
                .apellidos(surnames)
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

        ensureAttendedAppointment(patient, clinic);
        log.info("Paciente demo y recorrido histórico creados para la clínica piloto.");
    }

    private void ensureAttendedAppointment(Paciente patient, Clinica clinic) {
        if (citaRepository.existsDemoAppointment(
                patient.getIdUsuario(),
                clinic.getId(),
                EstadoCita.ATENDIDA,
                DEMO_APPOINTMENT_CHANNEL)) {
            return;
        }

        Odontologo dentist = odontologoRepository.findByUsuarioDni(DEMO_DENTIST_DNI)
                .orElseThrow(() -> new IllegalStateException(
                        "No existe el odontólogo asignado a la cita histórica demo."));
        ItemCatalogo service = itemCatalogoRepository.findByCodigoAndActivoTrue(DEMO_SERVICE_CODE)
                .orElseThrow(() -> new IllegalStateException(
                        "No existe el servicio asignado a la cita histórica demo."));
        Sede site = sedeRepository.findFirstByClinicaIdAndActivoTrueOrderByIdAsc(clinic.getId())
                .orElseThrow(() -> new IllegalStateException(
                        "No existe una sede activa para la cita histórica demo."));

        ZoneId zone = ZoneId.of(clinic.getZonaHoraria());
        OffsetDateTime start = OffsetDateTime.now(zone)
                .minusDays(42)
                .withHour(10)
                .withMinute(30)
                .withSecond(0)
                .withNano(0);

        citaRepository.save(Cita.builder()
                .paciente(patient)
                .odontologo(dentist)
                .fechaHora(start)
                .fechaHoraFin(start.plusMinutes(service.getDuracionMinutos()))
                .estado(EstadoCita.ATENDIDA)
                .canalOrigen(DEMO_APPOINTMENT_CHANNEL)
                .montoAdelanto(BigDecimal.ZERO)
                .clinica(clinic)
                .sede(site)
                .servicio(service)
                .notaPaciente("Evaluación odontológica completada")
                .creadoPor(patient.getUsuario())
                .fechaCreacion(start.minusDays(7))
                .fechaModificacion(start.plusMinutes(service.getDuracionMinutos()))
                .version(0L)
                .build());
    }

    private void validateConfiguration(
            String dni,
            String email,
            String password,
            String names,
            String surnames) {
        if (!dni.matches("\\d{8}")) {
            throw new IllegalStateException("DEMO_PATIENT_DNI debe contener exactamente 8 dígitos.");
        }
        if (!email.contains("@")) {
            throw new IllegalStateException("DEMO_PATIENT_EMAIL no tiene un formato válido.");
        }
        if (password.length() < 8) {
            throw new IllegalStateException("DEMO_PATIENT_PASSWORD debe tener al menos 8 caracteres.");
        }
        if (names.isBlank() || surnames.isBlank()) {
            throw new IllegalStateException("El nombre completo del paciente demo es obligatorio.");
        }
    }
}
