import Foundation

protocol AppointmentServicing {
    func fetchDentists(
        specialtyID: Int,
        completion: @escaping (Result<[Dentist], APIError>) -> Void
    )

    func fetchAvailability(
        dentistID: Int,
        serviceID: Int,
        date: String,
        completion: @escaping (Result<[AvailabilitySlot], APIError>) -> Void
    )

    func createAppointment(
        _ request: CreateAppointmentRequest,
        completion: @escaping (Result<PatientAppointment, APIError>) -> Void
    )
}

final class AppointmentService: AppointmentServicing {
    private let apiClient: APIClient
    private let sessionManager: SessionManager
    private let encoder: JSONEncoder

    init(
        apiClient: APIClient = APIClient(),
        sessionManager: SessionManager = .shared,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.apiClient = apiClient
        self.sessionManager = sessionManager
        self.encoder = encoder
    }

    func fetchDentists(
        specialtyID: Int,
        completion: @escaping (Result<[Dentist], APIError>) -> Void
    ) {
        sendAuthorizedGET(
            path: "/pacientes/me/odontologos",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "especialidadId", value: String(specialtyID))
            ],
            completion: completion
        )
    }

    func fetchAvailability(
        dentistID: Int,
        serviceID: Int,
        date: String,
        completion: @escaping (Result<[AvailabilitySlot], APIError>) -> Void
    ) {
        sendAuthorizedGET(
            path: "/pacientes/me/disponibilidad",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "odontologoId", value: String(dentistID)),
                URLQueryItem(name: "servicioId", value: String(serviceID)),
                URLQueryItem(name: "fecha", value: date)
            ],
            completion: completion
        )
    }

    func createAppointment(
        _ request: CreateAppointmentRequest,
        completion: @escaping (Result<PatientAppointment, APIError>) -> Void
    ) {
        do {
            let body = try encoder.encode(request)
            try performAuthorizedRequest(
                path: "/pacientes/me/citas",
                method: "POST",
                body: body,
                completion: completion
            )
        } catch let error as APIError {
            completion(.failure(error))
        } catch {
            completion(.failure(.invalidRequest))
        }
    }

    private func performAuthorizedRequest<Response: Decodable>(
        path: String,
        method: String,
        body: Data? = nil,
        queryItems: [URLQueryItem] = [],
        completion: @escaping (Result<Response, APIError>) -> Void
    ) throws {
        let request = try sessionManager.authorizedRequest(
            using: apiClient,
            path: path,
            method: method,
            body: body,
            queryItems: queryItems
        )
        apiClient.send(request, completion: completion)
    }

    private func sendAuthorizedGET<Response: Decodable>(
        path: String,
        method: String,
        queryItems: [URLQueryItem],
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        do {
            try performAuthorizedRequest(
                path: path,
                method: method,
                queryItems: queryItems,
                completion: completion
            )
        } catch let error as APIError {
            completion(.failure(error))
        } catch {
            completion(.failure(.invalidRequest))
        }
    }
}
