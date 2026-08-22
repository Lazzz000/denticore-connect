import Foundation

enum APIError: LocalizedError {
    case invalidRequest
    case transport(Error)
    case invalidResponse
    case unauthorized
    case forbidden
    case http(statusCode: Int, message: String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "No se pudo construir la solicitud."
        case .transport:
            return "No fue posible conectarse con el servidor."
        case .invalidResponse:
            return "El servidor devolvió una respuesta inválida."
        case .unauthorized:
            return "La sesión no es válida o las credenciales son incorrectas."
        case .forbidden:
            return "No tienes permisos para realizar esta operación."
        case let .http(statusCode, message):
            return message ?? "El servidor devolvió el código HTTP \(statusCode)."
        case .decoding:
            return "No se pudo interpretar la respuesta del servidor."
        }
    }
}

nonisolated struct APIErrorEnvelope: Decodable {
    let message: String?
    let error: String?

    var bestMessage: String? {
        message ?? error
    }
}
