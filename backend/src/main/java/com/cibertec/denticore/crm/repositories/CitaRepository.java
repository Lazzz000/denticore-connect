package com.cibertec.denticore.crm.repositories;

import com.cibertec.denticore.crm.entities.Cita;
import com.cibertec.denticore.crm.enums.EstadoCita;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface CitaRepository extends JpaRepository<Cita, Integer> {

    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Cita c " +
           "WHERE c.odontologo.idUsuario = :idOdontologo " +
           "AND c.fechaHora < :fin " +
           "AND c.fechaHoraFin > :inicio " +
           "AND c.estado IN :estados")
    boolean existeSolapamientoOdontologo(
            @Param("idOdontologo") Integer idOdontologo,
            @Param("inicio") OffsetDateTime inicio,
            @Param("fin") OffsetDateTime fin,
            @Param("estados") Collection<EstadoCita> estados);

    @Query("SELECT c FROM Cita c " +
           "WHERE c.odontologo.idUsuario = :idOdontologo " +
           "AND c.fechaHora < :fin " +
           "AND c.fechaHoraFin > :inicio " +
           "AND c.estado IN :estados " +
           "ORDER BY c.fechaHora ASC")
    List<Cita> findOcupadasByOdontologoAndRango(
            @Param("idOdontologo") Integer idOdontologo,
            @Param("inicio") OffsetDateTime inicio,
            @Param("fin") OffsetDateTime fin,
            @Param("estados") Collection<EstadoCita> estados);

    @Query("SELECT c FROM Cita c " +
           "WHERE c.paciente.idUsuario = :idPaciente " +
           "AND c.clinica.id = :idClinica " +
           "ORDER BY c.fechaHora DESC")
    List<Cita> findByPacienteAndClinica(
            @Param("idPaciente") Integer idPaciente,
            @Param("idClinica") Integer idClinica);

    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Cita c " +
           "WHERE c.paciente.idUsuario = :idPaciente " +
           "AND c.clinica.id = :idClinica " +
           "AND c.estado = :estado " +
           "AND c.canalOrigen = :canalOrigen")
    boolean existsDemoAppointment(
            @Param("idPaciente") Integer idPaciente,
            @Param("idClinica") Integer idClinica,
            @Param("estado") EstadoCita estado,
            @Param("canalOrigen") String canalOrigen);

    @Query("SELECT c FROM Cita c " +
           "JOIN FETCH c.odontologo o " +
           "JOIN FETCH o.usuario " +
           "JOIN FETCH c.servicio s " +
           "LEFT JOIN FETCH s.especialidad " +
           "JOIN FETCH c.sede " +
           "WHERE c.id = :idCita " +
           "AND c.paciente.idUsuario = :idPaciente " +
           "AND c.clinica.id = :idClinica")
    Optional<Cita> findDetailByIdAndPatientAndClinic(
            @Param("idCita") Integer idCita,
            @Param("idPaciente") Integer idPaciente,
            @Param("idClinica") Integer idClinica);

    @Query(value = "SELECT c FROM Cita c " +
                   "JOIN FETCH c.paciente p " +
                   "JOIN FETCH p.usuario " +
                   "JOIN FETCH c.odontologo o " +
                   "JOIN FETCH o.usuario " +
                   "WHERE c.fechaHora BETWEEN :inicio AND :fin " +
                   "ORDER BY c.fechaHora ASC",
           countQuery = "SELECT COUNT(c) FROM Cita c WHERE c.fechaHora BETWEEN :inicio AND :fin")
    Page<Cita> findByFechaHoraBetweenOrderByFechaHoraAsc(
            @Param("inicio") OffsetDateTime inicio,
            @Param("fin") OffsetDateTime fin,
            Pageable pageable);

    @Query(value = "SELECT c FROM Cita c " +
                   "JOIN FETCH c.paciente p " +
                   "JOIN FETCH p.usuario " +
                   "JOIN FETCH c.odontologo o " +
                   "JOIN FETCH o.usuario " +
                   "WHERE c.fechaHora >= :fechaInicio " +
                   "ORDER BY c.fechaHora ASC",
           countQuery = "SELECT COUNT(c) FROM Cita c WHERE c.fechaHora >= :fechaInicio")
    Page<Cita> findByFechaHoraGreaterThanEqualOrderByFechaHoraAsc(
            @Param("fechaInicio") OffsetDateTime fechaInicio,
            Pageable pageable);


        @Query(value = "SELECT c FROM Cita c " +
               "JOIN FETCH c.paciente p " +
               "JOIN FETCH p.usuario " +
               "JOIN FETCH c.odontologo o " +
               "JOIN FETCH o.usuario " +
               "WHERE c.odontologo.idUsuario = :idOdontologo " +
               "AND c.fechaHora BETWEEN :inicio AND :fin " +
               "ORDER BY c.fechaHora ASC",
       countQuery = "SELECT COUNT(c) FROM Cita c " +
                    "WHERE c.odontologo.idUsuario = :idOdontologo " +
                    "AND c.fechaHora BETWEEN :inicio AND :fin")
        Page<Cita> findAgendaDiariaByOdontologo(
                @Param("idOdontologo") Integer idOdontologo,
                @Param("inicio") OffsetDateTime inicio,
                @Param("fin") OffsetDateTime fin,
                Pageable pageable);
}
