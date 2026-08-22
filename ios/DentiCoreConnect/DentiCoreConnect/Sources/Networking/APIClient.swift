import Foundation

final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = AppConfiguration.apiBaseURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func makeRequest(
        path: String,
        method: String,
        body: Data? = nil,
        bearerToken: String? = nil,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let endpointURL = baseURL.appendingPathComponent(normalizedPath)
        var components = URLComponents(
            url: endpointURL,
            resolvingAgainstBaseURL: false
        )

        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url, url.scheme != nil else {
            throw APIError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = 75
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let bearerToken, !bearerToken.isEmpty {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    func send<Response: Decodable>(
        _ request: URLRequest,
        completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        session.dataTask(with: request) { [decoder] data, response, error in
            if let error {
                self.complete(.failure(.transport(error)), using: completion)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                self.complete(.failure(.invalidResponse), using: completion)
                return
            }

            let responseData = data ?? Data()

            guard (200...299).contains(httpResponse.statusCode) else {
                let message = try? decoder.decode(APIErrorEnvelope.self, from: responseData).bestMessage

                switch httpResponse.statusCode {
                case 401:
                    self.complete(.failure(.unauthorized), using: completion)
                case 403:
                    self.complete(.failure(.forbidden), using: completion)
                default:
                    self.complete(
                        .failure(.http(statusCode: httpResponse.statusCode, message: message)),
                        using: completion
                    )
                }
                return
            }

            do {
                let decodedResponse = try decoder.decode(Response.self, from: responseData)
                self.complete(.success(decodedResponse), using: completion)
            } catch {
                self.complete(.failure(.decoding(error)), using: completion)
            }
        }.resume()
    }

    private func complete<Response>(
        _ result: Result<Response, APIError>,
        using completion: @escaping (Result<Response, APIError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
