import Foundation

struct LoginRequest: Encodable {
    let dni: String
    let password: String
}

struct ClinicContext: Codable, Equatable {
    let id: Int
    let nombreComercial: String
    let zonaHoraria: String
}

struct LoginResponse: Decodable, Equatable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int?
    let role: String
    let clinicContext: ClinicContext?

    private enum CodingKeys: String, CodingKey {
        case accessToken
        case legacyToken = "token"
        case tokenType
        case expiresIn
        case role = "rol"
        case clinicContext = "contextoClinica"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let targetToken = try container.decodeIfPresent(String.self, forKey: .accessToken) {
            accessToken = targetToken
        } else {
            accessToken = try container.decode(String.self, forKey: .legacyToken)
        }

        tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType) ?? "Bearer"
        expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
        role = try container.decode(String.self, forKey: .role)
        clinicContext = try container.decodeIfPresent(ClinicContext.self, forKey: .clinicContext)
    }
}
