import Foundation

final class SessionManager {
    static let shared = SessionManager()

    private let tokenStore: SecureTokenStoring

    private(set) var role: String?
    private(set) var clinicContext: ClinicContext?

    init(tokenStore: SecureTokenStoring = KeychainService()) {
        self.tokenStore = tokenStore
    }

    var hasActiveSession: Bool {
        do {
            return try tokenStore.readToken() != nil
        } catch {
            return false
        }
    }

    func startSession(with response: LoginResponse) throws {
        try tokenStore.saveToken(response.accessToken)
        role = response.role
        clinicContext = response.clinicContext
    }

    func clearSession() {
        try? tokenStore.deleteToken()
        role = nil
        clinicContext = nil
    }

    func authorizedRequest(
        using apiClient: APIClient,
        path: String,
        method: String,
        body: Data? = nil
    ) throws -> URLRequest {
        let token = try tokenStore.readToken()

        guard let token, !token.isEmpty else {
            throw APIError.unauthorized
        }

        return try apiClient.makeRequest(
            path: path,
            method: method,
            body: body,
            bearerToken: token
        )
    }
}
