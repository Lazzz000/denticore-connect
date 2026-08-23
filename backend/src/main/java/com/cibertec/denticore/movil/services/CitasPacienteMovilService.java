package com.cibertec.denticore.movil.services;

import com.cibertec.denticore.agenda.entities.BloqueoHorario;
import com.cibertec.denticore.agenda.entities.HorarioOdontologo;
import com.cibertec.denticore.agenda.repositories.BloqueoHorarioRepository;
import com.cibertec.denticore.agenda.repositories.HorarioOdontologoRepository;
import com.cibertec.denticore.catalogo.entities.ItemCatalogo;
import com.cibertec.denticore.catalogo.repositories.ItemCatalogoRepository;
import com.cibertec.denticore.catalogo.repositories.OdontologoEspecialidadRepository;
import com.cibertec.denticore.common.ApiException;
import com.cibertec.denticore.crm.entities.Cita;
import com.cibertec.denticore.crm.enums.EstadoCita;
import com.cibertec.denticore.crm.repositories.CitaRepository;
import com.cibertec.denticore.movil.dto.CitaPacienteDTO;
import com.cibertec.denticore.movil.dto.CancelarCitaPacienteRequestDTO;
import com.cibertec.denticore.movil.dto.CrearCitaPacienteRequestDTO;
import com.cibertec.denticore.movil.dto.HorarioDisponibleDTO;
import com.cibertec.denticore.movil.dto.OdontologoMovilDTO;
import com.cibertec.denticore.organizacion.entities.Sede;
import com.cibertec.denticore.organizacion.repositories.SedeRepository;
import com.cibertec.denticore.security.entities.Odontologo;
import com.cibertec.denticore.security.entities.Paciente;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.repositories.OdontologoRepository;
import com.cibertec.denticore.security.repositories.PacienteRepository;
import com.cibertec.denticore.security.repositories.UsuarioClinicaRepository;
import com.cibertec.denticore.security.services.ContextoClinicaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CitasPacienteMovilService {

    private static final List<EstadoCita> ESTADOS_OCUPADOS = List.of(
            EstadoCita.PENDIENTE,
            EstadoCita.CONFIRMADA,
            EstadoCita.EN_SALA,
            EstadoCita.EN_CURSO);

    private static final List<EstadoCita> ESTADOS_CANCELABLES = List.of(
            EstadoCita.PENDIENTE,
            EstadoCita.CONFIRMADA);

    private final PacienteRepository pacienteRepository;
    private final OdontologoRepository odontologoRepository;
    private final OdontologoEspecialidadRepository odontologoEspecialidadRepository;
    private final UsuarioClinicaRepository usuarioClinicaRepository;
    private final ItemCatalogoRepository itemCatalogoRepository;
    private final SedeRepository sedeRepository;
    private final HorarioOdontologoRepository horarioRepository;
    private final BloqueoHorarioRepository bloqueoRepository;
    private final CitaRepository citaRepository;
    private final ContextoClinicaService contextoClinicaService;

    @Transactional(readOnly = true)
    public List<OdontologoMovilDTO> listarOdontologos(
            String dniPaciente, Integer especialidadId) {
        ContextoPaciente contexto = obtenerContexto(dniPaciente);

        return listarOdontologosAutorizados(contexto, especialidadId)
                .stream()
                .map(this::mapearOdontologo)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<HorarioDisponibleDTO> listarDisponibilidad(
            String dniPaciente,
            Integer odontologoId,
            Integer servicioId,
            LocalDate fecha) {
        ContextoPaciente contexto = obtenerContexto(dniPaciente);
        validarFechaConsulta(fecha, contexto.zonaHoraria());

        ItemCatalogo servicio = obtenerServicio(servicioId);
        Integer especialidadId = obtenerEspecialidadId(servicio);
        Odontologo odontologo = obtenerOdontologoAutorizado(
                contexto, odontologoId, especialidadId);

        return calcularDisponibilidad(
                contexto, odontologo, servicio, fecha);
    }

    @Transactional(readOnly = true)
    public List<CitaPacienteDTO> listarCitas(String dniPaciente) {
        ContextoPaciente contexto = obtenerContexto(dniPaciente);

        return citaRepository.findByPacienteAndClinica(
                        contexto.paciente().getIdUsuario(),
                        contexto.membresia().getClinica().getId())
                .stream()
                .map(cita -> mapearCita(cita, null))
                .toList();
    }

    @Transactional(readOnly = true)
    public CitaPacienteDTO obtenerCita(String dniPaciente, Integer citaId) {
        ContextoPaciente contexto = obtenerContexto(dniPaciente);
        return mapearCita(obtenerCitaAutorizada(contexto, citaId), null);
    }

    @Transactional
    public CitaPacienteDTO cancelarCita(
            String dniPaciente,
            Integer citaId,
            CancelarCitaPacienteRequestDTO request) {
        ContextoPaciente contexto = obtenerContexto(dniPaciente);
        Cita cita = obtenerCitaAutorizada(contexto, citaId);

        if (!ESTADOS_CANCELABLES.contains(cita.getEstado())) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "APPOINTMENT_NOT_CANCELLABLE",
                    "La cita ya no puede ser cancelada por el paciente.");
        }

        OffsetDateTime ahora = OffsetDateTime.now(contexto.zonaHoraria());
        if (!cita.getFechaHora().isAfter(ahora)) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "APPOINTMENT_ALREADY_STARTED",
                    "No es posible cancelar una cita cuya hora de inicio ya pasó.");
        }

        cita.setEstado(EstadoCita.CANCELADA_PACIENTE);
        cita.setMotivoCancelacion(normalizarNota(request.motivo()));
        cita.setCanceladaPor(contexto.paciente().getUsuario());
        cita.setFechaCancelacion(ahora);
        cita.setFechaModificacion(ahora);

        return mapearCita(
                citaRepository.saveAndFlush(cita),
                "Cita cancelada correctamente.");
    }

    @Transactional
    public CitaPacienteDTO crearCita(
            String dniPaciente, CrearCitaPacienteRequestDTO request) {
        ContextoPaciente contexto = obtenerContexto(dniPaciente);
        ItemCatalogo servicio = obtenerServicio(request.idServicio());
        Integer especialidadId = obtenerEspecialidadId(servicio);
        Odontologo odontologo = obtenerOdontologoAutorizado(
                contexto, request.idOdontologo(), especialidadId);

        ZoneId zona = contexto.zonaHoraria();
        OffsetDateTime inicio = request.fechaHora()
                .atZoneSameInstant(zona)
                .toOffsetDateTime();
        LocalDate fecha = inicio.toLocalDate();
        validarFechaConsulta(fecha, zona);

        boolean horarioValido = calcularDisponibilidad(
                contexto, odontologo, servicio, fecha).stream()
                .anyMatch(slot -> slot.fechaHoraInicio().isEqual(inicio));

        if (!horarioValido) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "APPOINTMENT_SLOT_UNAVAILABLE",
                    "El horario seleccionado ya no está disponible.");
        }

        int duracion = duracionServicio(servicio);
        OffsetDateTime fin = inicio.plusMinutes(duracion);

        Cita cita = Cita.builder()
                .paciente(contexto.paciente())
                .odontologo(odontologo)
                .fechaHora(inicio)
                .fechaHoraFin(fin)
                .estado(EstadoCita.PENDIENTE)
                .canalOrigen("IOS")
                .montoAdelanto(BigDecimal.ZERO)
                .clinica(contexto.membresia().getClinica())
                .sede(contexto.sede())
                .servicio(servicio)
                .notaPaciente(normalizarNota(request.notaPaciente()))
                .creadoPor(contexto.paciente().getUsuario())
                .fechaCreacion(OffsetDateTime.now())
                .version(0L)
                .build();

        Cita guardada = citaRepository.saveAndFlush(cita);
        return mapearCita(guardada, "Cita programada correctamente.");
    }

    private List<HorarioDisponibleDTO> calcularDisponibilidad(
            ContextoPaciente contexto,
            Odontologo odontologo,
            ItemCatalogo servicio,
            LocalDate fecha) {
        ZoneId zona = contexto.zonaHoraria();
        OffsetDateTime inicioDia = fecha.atStartOfDay(zona).toOffsetDateTime();
        OffsetDateTime finDia = fecha.plusDays(1).atStartOfDay(zona).toOffsetDateTime();

        List<HorarioOdontologo> horarios = horarioRepository.findVigentes(
                odontologo.getIdUsuario(),
                contexto.sede().getId(),
                (short) fecha.getDayOfWeek().getValue(),
                fecha);
        List<Cita> ocupadas = citaRepository.findOcupadasByOdontologoAndRango(
                odontologo.getIdUsuario(), inicioDia, finDia, ESTADOS_OCUPADOS);
        List<BloqueoHorario> bloqueos = bloqueoRepository.findActivosEnRango(
                odontologo.getIdUsuario(), contexto.sede().getId(), inicioDia, finDia);

        int duracion = duracionServicio(servicio);
        OffsetDateTime ahora = OffsetDateTime.now(zona).plusMinutes(15);
        List<HorarioDisponibleDTO> resultado = new ArrayList<>();

        for (HorarioOdontologo horario : horarios) {
            int intervalo = Math.max(5, horario.getIntervaloMinutos().intValue());
            LocalDateTime cursor = LocalDateTime.of(fecha, horario.getHoraInicio());
            LocalDateTime limite = LocalDateTime.of(fecha, horario.getHoraFin());

            while (!cursor.plusMinutes(duracion).isAfter(limite)) {
                OffsetDateTime inicio = cursor.atZone(zona).toOffsetDateTime();
                OffsetDateTime fin = inicio.plusMinutes(duracion);

                if (inicio.isAfter(ahora)
                        && !seSuperponeConCita(inicio, fin, ocupadas)
                        && !seSuperponeConBloqueo(inicio, fin, bloqueos)) {
                    resultado.add(new HorarioDisponibleDTO(inicio, fin));
                }

                cursor = cursor.plusMinutes(intervalo);
            }
        }

        return resultado.stream()
                .distinct()
                .sorted((a, b) -> a.fechaHoraInicio().compareTo(b.fechaHoraInicio()))
                .toList();
    }

    private boolean seSuperponeConCita(
            OffsetDateTime inicio, OffsetDateTime fin, List<Cita> citas) {
        return citas.stream().anyMatch(cita ->
                cita.getFechaHora().isBefore(fin)
                        && cita.getFechaHoraFin().isAfter(inicio));
    }

    private boolean seSuperponeConBloqueo(
            OffsetDateTime inicio,
            OffsetDateTime fin,
            List<BloqueoHorario> bloqueos) {
        return bloqueos.stream().anyMatch(bloqueo ->
                bloqueo.getFechaHoraInicio().isBefore(fin)
                        && bloqueo.getFechaHoraFin().isAfter(inicio));
    }

    private ContextoPaciente obtenerContexto(String dniPaciente) {
        Paciente paciente = pacienteRepository.findByUsuarioDni(dniPaciente)
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND,
                        "PATIENT_NOT_FOUND",
                        "No se encontró el paciente autenticado."));
        UsuarioClinica membresia = contextoClinicaService
                .obtenerMembresiaPrincipal(paciente.getIdUsuario());
        Sede sede = sedeRepository
                .findFirstByClinicaIdAndActivoTrueOrderByIdAsc(
                        membresia.getClinica().getId())
                .orElseThrow(() -> new ApiException(
                        HttpStatus.CONFLICT,
                        "ACTIVE_LOCATION_NOT_AVAILABLE",
                        "La clínica no tiene una sede activa configurada."));
        ZoneId zona = ZoneId.of(membresia.getClinica().getZonaHoraria());
        return new ContextoPaciente(paciente, membresia, sede, zona);
    }

    private ItemCatalogo obtenerServicio(Integer servicioId) {
        return itemCatalogoRepository
                .findByIdAndActivoTrueAndTipo(servicioId, "Servicio")
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND,
                        "SERVICE_NOT_FOUND",
                        "El servicio seleccionado no está disponible."));
    }

    private Cita obtenerCitaAutorizada(
            ContextoPaciente contexto, Integer citaId) {
        return citaRepository.findDetailByIdAndPatientAndClinic(
                        citaId,
                        contexto.paciente().getIdUsuario(),
                        contexto.membresia().getClinica().getId())
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND,
                        "APPOINTMENT_NOT_FOUND",
                        "No se encontró la cita solicitada."));
    }

    private Integer obtenerEspecialidadId(ItemCatalogo servicio) {
        if (servicio.getEspecialidad() == null) {
            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "SERVICE_WITHOUT_SPECIALTY",
                    "El servicio no tiene una especialidad configurada.");
        }
        return servicio.getEspecialidad().getId();
    }

    private Odontologo obtenerOdontologoAutorizado(
            ContextoPaciente contexto,
            Integer odontologoId,
            Integer especialidadId) {
        return listarOdontologosAutorizados(contexto, especialidadId).stream()
                .filter(item -> item.getIdUsuario().equals(odontologoId))
                .findFirst()
                .orElseThrow(() -> new ApiException(
                        HttpStatus.NOT_FOUND,
                        "DENTIST_NOT_AVAILABLE",
                        "El odontólogo no atiende la especialidad seleccionada."));
    }

    private List<Odontologo> listarOdontologosAutorizados(
            ContextoPaciente contexto, Integer especialidadId) {
        Integer clinicaId = contexto.membresia().getClinica().getId();

        return odontologoRepository.findAll().stream()
                .filter(item -> Boolean.TRUE.equals(item.getActivo()))
                .filter(item -> Boolean.TRUE.equals(item.getUsuario().getActivo()))
                .filter(item -> odontologoEspecialidadRepository
                        .existsById_IdOdontologoAndId_IdEspecialidad(
                                item.getIdUsuario(), especialidadId))
                .filter(item -> usuarioClinicaRepository
                        .existsById_IdUsuarioAndId_IdClinicaAndActivoTrue(
                                item.getIdUsuario(), clinicaId))
                .sorted(Comparator
                        .comparing((Odontologo item) -> item.getUsuario().getApellidos())
                        .thenComparing(item -> item.getUsuario().getNombres()))
                .toList();
    }

    private void validarFechaConsulta(LocalDate fecha, ZoneId zona) {
        LocalDate hoy = LocalDate.now(zona);
        if (fecha.isBefore(hoy) || fecha.isAfter(hoy.plusDays(60))) {
            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "APPOINTMENT_DATE_OUT_OF_RANGE",
                    "Selecciona una fecha entre hoy y los próximos 60 días.");
        }
    }

    private int duracionServicio(ItemCatalogo servicio) {
        return servicio.getDuracionMinutos() != null
                && servicio.getDuracionMinutos() > 0
                ? servicio.getDuracionMinutos()
                : 30;
    }

    private String normalizarNota(String nota) {
        if (nota == null || nota.isBlank()) {
            return null;
        }
        return nota.trim();
    }

    private OdontologoMovilDTO mapearOdontologo(Odontologo odontologo) {
        String nombres = odontologo.getUsuario().getNombres();
        String apellidos = odontologo.getUsuario().getApellidos();
        return new OdontologoMovilDTO(
                odontologo.getIdUsuario(),
                nombres,
                apellidos,
                nombres + " " + apellidos,
                odontologo.getCop());
    }

    private CitaPacienteDTO mapearCita(Cita cita, String mensaje) {
        String odontologoNombre = cita.getOdontologo().getUsuario().getNombres()
                + " " + cita.getOdontologo().getUsuario().getApellidos();
        String especialidadNombre = cita.getServicio().getEspecialidad() == null
                ? null
                : cita.getServicio().getEspecialidad().getNombre();

        return new CitaPacienteDTO(
                cita.getId(),
                cita.getEstado().name(),
                cita.getFechaHora(),
                cita.getFechaHoraFin(),
                odontologoNombre,
                cita.getServicio().getNombre(),
                especialidadNombre,
                cita.getSede().getNombre(),
                cita.getNotaPaciente(),
                mensaje);
    }

    private record ContextoPaciente(
            Paciente paciente,
            UsuarioClinica membresia,
            Sede sede,
            ZoneId zonaHoraria) {
    }
}
