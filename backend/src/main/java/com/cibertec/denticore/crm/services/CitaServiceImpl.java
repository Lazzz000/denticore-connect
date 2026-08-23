package com.cibertec.denticore.crm.services;

import com.cibertec.denticore.crm.dto.request.ActualizarEstadoDTO;
import com.cibertec.denticore.crm.dto.request.CitaRequestDTO;
import com.cibertec.denticore.crm.dto.response.CitaListadoDTO;
import com.cibertec.denticore.crm.dto.response.CitaResponseDTO;
import com.cibertec.denticore.crm.entities.Cita;
import com.cibertec.denticore.crm.enums.EstadoCita;
import com.cibertec.denticore.crm.repositories.CitaRepository;
import com.cibertec.denticore.security.entities.Odontologo;
import com.cibertec.denticore.security.entities.Paciente;
import com.cibertec.denticore.security.repositories.OdontologoRepository;
import com.cibertec.denticore.security.repositories.PacienteRepository;
import com.cibertec.denticore.catalogo.entities.ItemCatalogo;
import com.cibertec.denticore.catalogo.repositories.ItemCatalogoRepository;
import com.cibertec.denticore.organizacion.entities.Sede;
import com.cibertec.denticore.organizacion.repositories.SedeRepository;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.services.ContextoClinicaService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CitaServiceImpl implements CitaService {

    private final CitaRepository citaRepository;
    private final PacienteRepository pacienteRepository;
    private final OdontologoRepository odontologoRepository;
    private final ItemCatalogoRepository itemCatalogoRepository;
    private final SedeRepository sedeRepository;
    private final ContextoClinicaService contextoClinicaService;

    private static final ZoneId ZONA_PILOTO = ZoneId.of("America/Lima");
    private static final List<EstadoCita> ESTADOS_OCUPADOS = List.of(
            EstadoCita.PENDIENTE,
            EstadoCita.CONFIRMADA,
            EstadoCita.EN_SALA,
            EstadoCita.EN_CURSO);

    @Override
    @Transactional
    public CitaResponseDTO programarCita(CitaRequestDTO dto, String dniUsuarioAutenticado) {
        Paciente paciente = obtenerPaciente(dto, dniUsuarioAutenticado);
        UsuarioClinica membresia = contextoClinicaService
                .obtenerMembresiaPrincipal(paciente.getIdUsuario());
        Sede sede = sedeRepository
                .findFirstByClinicaIdAndActivoTrueOrderByIdAsc(membresia.getClinica().getId())
                .orElseThrow(() -> new RuntimeException("Sede activa no encontrada"));
        ItemCatalogo servicio = itemCatalogoRepository
                .findByCodigoAndActivoTrue("CONSULTA-GENERAL")
                .orElseThrow(() -> new RuntimeException("Servicio general no configurado"));

        OffsetDateTime inicio = dto.getFechaHora().atZone(ZONA_PILOTO).toOffsetDateTime();
        OffsetDateTime fin = inicio.plusMinutes(
                servicio.getDuracionMinutos() > 0 ? servicio.getDuracionMinutos() : 30);

        boolean existeColision = citaRepository.existeSolapamientoOdontologo(
                dto.getIdOdontologo(), inicio, fin, ESTADOS_OCUPADOS);

        if (existeColision) {
            throw new IllegalStateException("El odontólogo ya tiene una cita reservada en este horario.");
        }

        Odontologo odontologo = odontologoRepository.findById(dto.getIdOdontologo())
                .orElseThrow(() -> new RuntimeException("Odontólogo no encontrado"));

        Cita cita = new Cita();
        cita.setPaciente(paciente);
        cita.setOdontologo(odontologo);
        cita.setFechaHora(inicio);
        cita.setFechaHoraFin(fin);
        cita.setEstado(EstadoCita.PENDIENTE);
        cita.setCanalOrigen(dto.getCanalOrigen());
        cita.setMontoAdelanto(dto.getMontoAdelanto() != null ? dto.getMontoAdelanto() : BigDecimal.ZERO);
        cita.setReferenciaAdelanto(dto.getReferenciaAdelanto());
        cita.setClinica(membresia.getClinica());
        cita.setSede(sede);
        cita.setServicio(servicio);
        cita.setCreadoPor(paciente.getUsuario());
        cita.setFechaCreacion(OffsetDateTime.now());
        cita.setVersion(0L);

        Cita guardada = citaRepository.save(cita);

        return mapearRespuesta(guardada, "Cita programada correctamente");
    }

    @Override
    @Transactional(readOnly = true)
    public Page<CitaListadoDTO> listarAgendaDiaria(LocalDate fecha, Pageable pageable) {
        LocalDate fechaConsulta = fecha != null ? fecha : LocalDate.now();
        OffsetDateTime inicio = fechaConsulta.atStartOfDay(ZONA_PILOTO).toOffsetDateTime();
        OffsetDateTime fin = fechaConsulta.plusDays(1).atStartOfDay(ZONA_PILOTO)
                .toOffsetDateTime().minusNanos(1);

        Page<Cita> citas = citaRepository.findByFechaHoraBetweenOrderByFechaHoraAsc(inicio, fin, pageable);

        return citas.map(this::mapearCitaListado);
    }

    @Override
    @Transactional
    public CitaResponseDTO actualizarEstado(Integer idCita, ActualizarEstadoDTO dto) {
        Cita cita = citaRepository.findById(idCita)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));

        cita.setEstado(dto.getEstado());

        Cita actualizada = citaRepository.save(cita);

        return mapearRespuesta(actualizada, "Estado de cita actualizado");
    }

    private Paciente obtenerPaciente(CitaRequestDTO dto, String dniUsuarioAutenticado) {
        if (dto.getIdPaciente() != null) {
            return pacienteRepository.findById(dto.getIdPaciente())
                    .orElseThrow(() -> new RuntimeException("Paciente no encontrado"));
        }

        return pacienteRepository.findByUsuarioDni(dniUsuarioAutenticado)
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado para el usuario autenticado"));
    }

    private CitaListadoDTO mapearCitaListado(Cita cita) {
        CitaListadoDTO dto = new CitaListadoDTO();
        dto.setIdCita(cita.getId());
        dto.setFechaHora(cita.getFechaHora());
        dto.setIdPaciente(cita.getPaciente().getUsuario().getId());
        dto.setPacienteNombreCompleto(
                cita.getPaciente().getUsuario().getNombres() + " " + cita.getPaciente().getUsuario().getApellidos());
        dto.setPacienteDni(cita.getPaciente().getUsuario().getDni());
        dto.setIdOdontologo(cita.getOdontologo().getUsuario().getId());
        dto.setOdontologoNombre(
                cita.getOdontologo().getUsuario().getNombres() + " " + cita.getOdontologo().getUsuario().getApellidos());
        dto.setEstado(cita.getEstado().name());
        dto.setMontoAdelanto(cita.getMontoAdelanto());
        return dto;
    }

    private CitaResponseDTO mapearRespuesta(Cita cita, String mensaje) {
        CitaResponseDTO dto = new CitaResponseDTO();
        dto.setId(cita.getId());
        dto.setEstado(cita.getEstado().name());
        dto.setFechaHora(cita.getFechaHora());
        dto.setMensaje(mensaje);
        return dto;
    }

    @Override
@Transactional(readOnly = true)
public Page<CitaListadoDTO> listarMisCitas(
        String dniUsuarioAutenticado,
        LocalDate fecha,
        Pageable pageable) {

    LocalDate fechaConsulta = fecha != null ? fecha : LocalDate.now();
    OffsetDateTime inicio = fechaConsulta.atStartOfDay(ZONA_PILOTO).toOffsetDateTime();
    OffsetDateTime fin = fechaConsulta.plusDays(1).atStartOfDay(ZONA_PILOTO)
            .toOffsetDateTime().minusNanos(1);

    Odontologo odontologo = odontologoRepository
            .findByUsuarioDni(dniUsuarioAutenticado)
            .orElseThrow(() -> new RuntimeException("Odontólogo no encontrado"));

     return citaRepository
            .findAgendaDiariaByOdontologo(
                    odontologo.getIdUsuario(),
                    inicio,
                    fin,
                    pageable)
            .map(this::mapearCitaListado);
    }
}
