import Foundation

nonisolated struct PatientProfile: Decodable, Equatable {
    let id: Int
    let dni: String
    let nombres: String
    let apellidos: String
    let correo: String?
    let fechaNacimiento: String?
    let clinica: ClinicContext

    var fullName: String {
        "\(nombres) \(apellidos)"
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var firstName: String {
        nombres.split(separator: " ").first.map(String.init) ?? nombres
    }
}
