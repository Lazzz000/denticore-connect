import Foundation

enum AppConfiguration {
    private static let apiBaseURLKey = "API_BASE_URL"

    static var apiBaseURL: URL {
        let configuredValue = Bundle.main.object(forInfoDictionaryKey: apiBaseURLKey) as? String
        let normalizedValue = configuredValue?.trimmingCharacters(in: .whitespacesAndNewlines)

        #if DEBUG
        let fallbackValue = "http://localhost:8080"
        #else
        let fallbackValue = ""
        #endif

        let rawValue = (normalizedValue?.isEmpty == false) ? normalizedValue! : fallbackValue

        guard !rawValue.isEmpty, let url = URL(string: rawValue) else {
            preconditionFailure("Configura una URL válida en la clave API_BASE_URL del Info.plist.")
        }

        return url
    }
}
