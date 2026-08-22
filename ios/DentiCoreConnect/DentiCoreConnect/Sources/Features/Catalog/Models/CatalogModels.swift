import Foundation

nonisolated struct Specialty: Decodable, Equatable {
    let id: Int
    let nombre: String
}

nonisolated struct DentalService: Decodable, Equatable {
    let id: Int
    let codigo: String?
    let nombre: String
    let especialidadId: Int?
    let duracionMinutos: Int?
    let costoReferencial: Double?
    let moneda: String?
    let activo: Bool?
}
