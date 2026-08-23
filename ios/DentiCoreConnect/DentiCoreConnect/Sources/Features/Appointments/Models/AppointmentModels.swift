import Foundation

nonisolated struct Dentist: Decodable, Equatable {
    let id: Int
    let nombres: String?
    let apellidos: String?
    let nombreCompleto: String
    let cop: String?
}

nonisolated struct AvailabilitySlot: Decodable, Equatable {
    let fechaHoraInicio: String
    let fechaHoraFin: String
}

nonisolated struct CreateAppointmentRequest: Encodable {
    let idOdontologo: Int
    let idServicio: Int
    let fechaHora: String
    let notaPaciente: String?
}

nonisolated struct PatientAppointment: Decodable, Equatable {
    let id: Int
    let estado: String
    let fechaHora: String
    let fechaHoraFin: String
    let odontologoNombre: String
    let servicioNombre: String
    let especialidadNombre: String?
    let sedeNombre: String
    let notaPaciente: String?
    let mensaje: String?
}
