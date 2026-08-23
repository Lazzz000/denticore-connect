//
//  DentiCoreConnectTests.swift
//  DentiCoreConnectTests
//
//  Created by user258863 on 8/22/26.
//

import XCTest
@testable import DentiCoreConnect

final class DentiCoreConnectTests: XCTestCase {
    func testAttendedAppointmentIsReadOnlyForPatient() {
        let appointment = makeAppointment(status: "ATENDIDA")

        XCTAssertEqual(AppointmentPresentation.displayStatus(appointment.estado), "Atendida")
        XCTAssertFalse(AppointmentPresentation.canPatientCancel(appointment))
    }

    func testPendingAppointmentCanBeCanceled() {
        XCTAssertTrue(
            AppointmentPresentation.canPatientCancel(
                makeAppointment(status: "PENDIENTE")
            )
        )
    }

    private func makeAppointment(status: String) -> PatientAppointment {
        PatientAppointment(
            id: 1,
            estado: status,
            fechaHora: "2026-07-12T10:30:00-05:00",
            fechaHoraFin: "2026-07-12T11:00:00-05:00",
            odontologoNombre: "Dra. Ana Lucía Torres Quiroz",
            servicioNombre: "Evaluación odontológica integral",
            especialidadNombre: "Odontología general",
            sedeNombre: "Sede principal",
            notaPaciente: "Evaluación completada",
            mensaje: nil
        )
    }
}
