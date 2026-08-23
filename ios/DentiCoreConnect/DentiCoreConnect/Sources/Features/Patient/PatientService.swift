import Foundation

protocol PatientServicing {
    func fetchCurrentPatient(
        completion: @escaping (Result<PatientProfile, APIError>) -> Void
    )
}

final class PatientService: PatientServicing {
    private let apiClient: APIClient
    private let sessionManager: SessionManager

    init(
        apiClient: APIClient = APIClient(),
        sessionManager: SessionManager = .shared
    ) {
        self.apiClient = apiClient
        self.sessionManager = sessionManager
    }

    func fetchCurrentPatient(
        completion: @escaping (Result<PatientProfile, APIError>) -> Void
    ) {
        do {
            let request = try sessionManager.authorizedRequest(
                using: apiClient,
                path: "/pacientes/me",
                method: "GET"
            )
            apiClient.send(request, completion: completion)
        } catch let apiError as APIError {
            completion(.failure(apiError))
        } catch {
            completion(.failure(.invalidRequest))
        }
    }
}
