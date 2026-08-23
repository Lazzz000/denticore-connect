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
import java.util.List;

@Slf4j
@Service
@Profile("demo")
@RequiredArgsConstructor
public class DemoPatientBootstrapService {

    private static final String PILOT_CLINIC_CODE = "PILOTO-001";
    private static final String PRIMARY_DEMO_DENTIST_DNI = "73000001";
    private static final String NOTIFICATION_DEMO_DENTIST_DNI = "73000003";
    private static final String NOTIFICATION_DEMO_SERVICE_CODE = "GEN-LIMP";
    private static final String NOTIFICATION_DEMO_CHANNEL = "DEMO_NOTIFICATION";
    private static final List<EstadoCita> ACTIVE_APPOINTMENT_STATES = List.of(
            EstadoCita.PENDIENTE,
            EstadoCita.CONFIRMADA,
            EstadoCita.EN_SALA,
            EstadoCita.EN_CURSO);

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
            synchronizeDemoScenario(existingPatient, clinic);
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

        synchronizeDemoScenario(patient, clinic);
        log.info("Paciente demo y recorrido histórico creados para la clínica piloto.");
    }

    private void synchronizeDemoScenario(Paciente patient, Clinica clinic) {
        ensureAttendedAppointment(
                patient,
                clinic,
                "DEMO_SEED",
                PRIMARY_DEMO_DENTIST_DNI,
                "GEN-EVAL",
                42,
                "Evaluación odontológica completada");
        ensureAttendedAppointment(
                patient,
                clinic,
                "DEMO_HISTORY_2",
                NOTIFICATION_DEMO_DENTIST_DNI,
                "GEN-LIMP",
                84,
                "Profilaxis y limpieza dental completadas");
        ensureAttendedAppointment(
                patient,
                clinic,
                "DEMO_HISTORY_3",
                PRIMARY_DEMO_DENTIST_DNI,
                "ORT-EVAL",
                126,
                "Evaluación de ortodoncia completada");
        synchronizeNotificationAppointment(patient, clinic);
    }

    private void ensureAttendedAppointment(
            Paciente patient,
            Clinica clinic,
            String channel,
            String dentistDni,
            String serviceCode,
            long daysAgo,
            String note) {
        if (citaRepository.existsDemoAppointment(
                patient.getIdUsuario(),
                clinic.getId(),
                EstadoCita.ATENDIDA,
                channel)) {
            return;
        }

        Odontologo dentist = odontologoRepository.findByUsuarioDni(dentistDni)
                .orElseThrow(() -> new IllegalStateException(
                        "No existe el odontólogo asignado a la cita histórica demo."));
        ItemCatalogo service = itemCatalogoRepository.findByCodigoAndActivoTrue(serviceCode)
                .orElseThrow(() -> new IllegalStateException(
                        "No existe el servicio asignado a la cita histórica demo."));
        Sede site = sedeRepository.findFirstByClinicaIdAndActivoTrueOrderByIdAsc(clinic.getId())
                .orElseThrow(() -> new IllegalStateException(
                        "No existe una sede activa para la cita histórica demo."));

        ZoneId zone = ZoneId.of(clinic.getZonaHoraria());
        OffsetDateTime start = OffsetDateTime.now(zone)
                .minusDays(daysAgo)
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
                .canalOrigen(channel)
                .montoAdelanto(BigDecimal.ZERO)
                .clinica(clinic)
                .sede(site)
                .servicio(service)
                .notaPaciente(note)
                .creadoPor(patient.getUsuario())
                .fechaCreacion(start.minusDays(7))
                .fechaModificacion(start.plusMinutes(service.getDuracionMinutos()))
                .version(0L)
                .build());
    }

    private void synchronizeNotificationAppointment(Paciente patient, Clinica clinic) {
        Odontologo dentist = odontologoRepository.findByUsuarioDni(NOTIFICATION_DEMO_DENTIST_DNI)
                .orElseThrow(() -> new IllegalStateException(
                        "No existe el odontólogo asignado a la cita de notificación demo."));
        ItemCatalogo service = itemCatalogoRepository
                .findByCodigoAndActivoTrue(NOTIFICATION_DEMO_SERVICE_CODE)
                .orElseThrow(() -> new IllegalStateException(
                        "No existe el servicio asignado a la cita de notificación demo."));
        Sede site = sedeRepository.findFirstByClinicaIdAndActivoTrueOrderByIdAsc(clinic.getId())
                .orElseThrow(() -> new IllegalStateException(
                        "No existe una sede activa para la cita de notificación demo."));

        Cita appointment = citaRepository.findDemoAppointment(
                        patient.getIdUsuario(),
                        clinic.getId(),
                        NOTIFICATION_DEMO_CHANNEL)
                .orElseGet(Cita::new);

        ZoneId zone = ZoneId.of(clinic.getZonaHoraria());
        OffsetDateTime start = OffsetDateTime.now(zone)
                .plusMinutes(15)
                .withSecond(0)
                .withNano(0);
        OffsetDateTime end = start.plusMinutes(service.getDuracionMinutos());

        boolean available = false;
        for (int attempt = 0; attempt < 12; attempt++) {
            boolean occupied = citaRepository.existeSolapamientoOdontologoExcluyendoCita(
                    dentist.getIdUsuario(),
                    start,
                    end,
                    ACTIVE_APPOINTMENT_STATES,
                    appointment.getId());
            if (!occupied) {
                available = true;
                break;
            }
            start = start.plusMinutes(5);
            end = start.plusMinutes(service.getDuracionMinutos());
        }
        if (!available) {
            throw new IllegalStateException(
                    "No se encontró un intervalo próximo para la cita de notificación demo.");
        }

        appointment.setPaciente(patient);
        appointment.setOdontologo(dentist);
        appointment.setFechaHora(start);
        appointment.setFechaHoraFin(end);
        appointment.setEstado(EstadoCita.PENDIENTE);
        appointment.setCanalOrigen(NOTIFICATION_DEMO_CHANNEL);
        appointment.setMontoAdelanto(BigDecimal.ZERO);
        appointment.setReferenciaAdelanto(null);
        appointment.setClinica(clinic);
        appointment.setSede(site);
        appointment.setServicio(service);
        appointment.setNotaPaciente("Cita próxima para demostración de recordatorio local");
        appointment.setMotivoCancelacion(null);
        appointment.setCanceladaPor(null);
        appointment.setFechaCancelacion(null);
        appointment.setCreadoPor(patient.getUsuario());
        if (appointment.getId() == null) {
            appointment.setFechaCreacion(OffsetDateTime.now(zone));
        }
        appointment.setFechaModificacion(OffsetDateTime.now(zone));

        citaRepository.saveAndFlush(appointment);
        log.info("Cita demo de notificación sincronizada para {}.", start);
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
