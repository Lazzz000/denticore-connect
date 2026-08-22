import Foundation

protocol AuthServicing {
    func login(
        dni: String,
        password: String,
        completion: @escaping (Result<LoginResponse, APIError>) -> Void
    )
}

final class AuthService: AuthServicing {
    private let apiClient: APIClient
    private let encoder: JSONEncoder

    init(
        apiClient: APIClient = APIClient(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.apiClient = apiClient
        self.encoder = encoder
    }

    func login(
        dni: String,
        password: String,
        completion: @escaping (Result<LoginResponse, APIError>) -> Void
    ) {
        do {
            let body = try encoder.encode(LoginRequest(dni: dni, password: password))
            let request = try apiClient.makeRequest(
                path: "/auth/login",
                method: "POST",
                body: body
            )
            apiClient.send(request, completion: completion)
        } catch let apiError as APIError {
            DispatchQueue.main.async {
                completion(.failure(apiError))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.invalidRequest))
            }
        }
    }
}
