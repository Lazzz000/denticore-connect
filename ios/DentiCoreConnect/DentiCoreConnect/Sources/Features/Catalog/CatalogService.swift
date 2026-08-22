import Foundation

protocol CatalogServicing {
    func fetchSpecialties(
        completion: @escaping (Result<[Specialty], APIError>) -> Void
    )

    func fetchServices(
        specialtyID: Int?,
        completion: @escaping (Result<[DentalService], APIError>) -> Void
    )
}

final class CatalogService: CatalogServicing {
    private let apiClient: APIClient
    private let sessionManager: SessionManager

    init(
        apiClient: APIClient = APIClient(),
        sessionManager: SessionManager = .shared
    ) {
        self.apiClient = apiClient
        self.sessionManager = sessionManager
    }

    func fetchSpecialties(
        completion: @escaping (Result<[Specialty], APIError>) -> Void
    ) {
        sendAuthorizedGET(
            path: "/especialidades",
            queryItems: [],
            completion: completion
        )
    }

    func fetchServices(
        specialtyID: Int?,
        completion: @escaping (Result<[DentalService], APIError>) -> Void
    ) {
        let queryItems = specialtyID.map {
            [URLQueryItem(name: "especialidadId", value: String($0))]
        } ?? []

        sendAuthorizedGET(
            path: "/servicios",
            queryItems: queryItems,
            completion: completion
        )
    }

    private func sendAuthorizedGET<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        do {
            let request = try sessionManager.authorizedRequest(
                using: apiClient,
                path: path,
                method: "GET",
                queryItems: queryItems
            )
            apiClient.send(request, completion: completion)
        } catch let apiError as APIError {
            completion(.failure(apiError))
        } catch {
            completion(.failure(.invalidRequest))
        }
    }
}
