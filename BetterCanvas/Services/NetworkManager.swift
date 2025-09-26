import Foundation

/// Manages network requests with URLSession and async/await
class NetworkManager {
    
    // MARK: - Properties
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        
        // Configure JSON decoder for Canvas API
        self.decoder = JSONDecoder()
        
        // Use flexible date decoding strategy for Canvas API
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try multiple date formats that Canvas might use
            let formatters = [
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ss'Z'",
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd HH:mm:ss"
            ]
            
            for format in formatters {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            // If all formats fail, try ISO8601 decoder
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        // Configure JSON encoder
        self.encoder = JSONEncoder()
        let encoderDateFormatter = DateFormatter()
        encoderDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        encoderDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        encoderDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        encoder.dateEncodingStrategy = .formatted(encoderDateFormatter)
    }
    
    // MARK: - Public Methods
    
    /// Performs a network request and returns decoded response
    func request<T: Codable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequest(for: endpoint)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            try validateResponse(response, data: data)
            
            // Debug: Print raw JSON response for troubleshooting
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔍 Raw JSON Response for \(endpoint.path):")
                print(jsonString) // Print full JSON response without truncation
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ JSON Decoding Error for \(endpoint.path): \(error)")
                if let decodingError = error as? DecodingError {
                    print("❌ Decoding Error Details: \(decodingError)")
                }
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    /// Performs a network request without expecting a response body
    func request(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(for: endpoint)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            try validateResponse(response, data: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    /// Uploads data with progress tracking
    func upload<T: Codable>(
        _ endpoint: APIEndpoint,
        data: Data,
        responseType: T.Type,
        progressHandler: @escaping (Double) -> Void = { _ in }
    ) async throws -> T {
        let request = try buildRequest(for: endpoint)
        
        do {
            let (responseData, response) = try await urlSession.upload(for: request, from: data)
            
            try validateResponse(response, data: responseData)
            
            return try decoder.decode(T.self, from: responseData)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.fullURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = endpoint.timeout
        
        // Add headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if present
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400:
            throw NetworkError.badRequest(parseErrorMessage(from: data))
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            throw NetworkError.rateLimited
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknownError(httpResponse.statusCode)
        }
    }
    
    private func parseErrorMessage(from data: Data) -> String {
        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            return errorResponse.message
        }
        return "Unknown error occurred"
    }
}

// MARK: - Supporting Types

/// Represents an API endpoint configuration
struct APIEndpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: Codable?
    let timeout: TimeInterval
    
    var fullURL: String {
        return baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
    
    init(
        baseURL: String,
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        body: Codable? = nil,
        timeout: TimeInterval = 30.0
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}

/// HTTP methods supported by the API
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

/// Network-related errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest(String)
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case networkError(Error)
    case decodingError(Error)
    case unknownError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error (\(code))"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data parsing error: \(error.localizedDescription)"
        case .unknownError(let code):
            return "Unknown error (\(code))"
        }
    }
}

/// API error response structure
struct APIErrorResponse: Codable {
    let message: String
    let errors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case errors
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Canvas API sometimes returns different error formats
        if let message = try? container.decode(String.self, forKey: .message) {
            self.message = message
        } else if let errors = try? container.decode([String].self, forKey: .errors) {
            self.message = errors.first ?? "Unknown error"
        } else {
            self.message = "Unknown error"
        }
        
        self.errors = try? container.decode([String].self, forKey: .errors)
    }
}