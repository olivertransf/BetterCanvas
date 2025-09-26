import XCTest
@testable import BetterCanvas

final class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkManager = NetworkManager(urlSession: mockURLSession)
    }
    
    override func tearDown() {
        networkManager = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testSuccessfulRequest() async throws {
        // Given
        let expectedUser = User(id: "123", name: "Test User", email: "test@example.com", avatarURL: nil)
        let userData = try JSONEncoder().encode(expectedUser)
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (userData, response)
        
        let endpoint = APIEndpoint(
            baseURL: "https://test.com",
            path: "api",
            headers: ["Authorization": "Bearer token"]
        )
        
        // When
        let result = try await networkManager.request(endpoint, responseType: User.self)
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.name, expectedUser.name)
        XCTAssertEqual(result.email, expectedUser.email)
    }
    
    func testSuccessfulRequestWithoutResponse() async throws {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 204,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (Data(), response)
        
        let endpoint = APIEndpoint(
            baseURL: "https://test.com",
            path: "api",
            method: .POST
        )
        
        // When/Then
        try await networkManager.request(endpoint)
        // Should not throw
    }
    
    // MARK: - Error Tests
    
    func testInvalidURL() async {
        // Given
        let endpoint = APIEndpoint(
            baseURL: "",
            path: "invalid url with spaces",
            headers: [:]
        )
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected invalid URL error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testUnauthorizedError() async {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (Data(), response)
        
        let endpoint = APIEndpoint(
            baseURL: "https://test.com",
            path: "api"
        )
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected unauthorized error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testForbiddenError() async {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (Data(), response)
        
        let endpoint = APIEndpoint(baseURL: "https://test.com", path: "api")
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected forbidden error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .forbidden)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testNotFoundError() async {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (Data(), response)
        
        let endpoint = APIEndpoint(baseURL: "https://test.com", path: "api")
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected not found error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRateLimitedError() async {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (Data(), response)
        
        let endpoint = APIEndpoint(baseURL: "https://test.com", path: "api")
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected rate limited error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .rateLimited)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testServerError() async {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (Data(), response)
        
        let endpoint = APIEndpoint(baseURL: "https://test.com", path: "api")
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected server error")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected server error with code 500")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testBadRequestWithErrorMessage() async {
        // Given
        let errorResponse = APIErrorResponse(message: "Invalid parameters", errors: ["Field is required"])
        let errorData = try! JSONEncoder().encode(errorResponse)
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/api")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (errorData, response)
        
        let endpoint = APIEndpoint(baseURL: "https://test.com", path: "api")
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected bad request error")
        } catch let error as NetworkError {
            if case .badRequest(let message) = error {
                XCTAssertEqual(message, "Invalid parameters")
            } else {
                XCTFail("Expected bad request error with message")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testNetworkError() async {
        // Given
        let networkError = URLError(.notConnectedToInternet)
        mockURLSession.mockError = networkError
        
        let endpoint = APIEndpoint(baseURL: "https://test.com", path: "api")
        
        // When/Then
        do {
            _ = try await networkManager.request(endpoint, responseType: User.self)
            XCTFail("Expected network error")
        } catch let error as NetworkError {
            if case .networkError(let underlyingError) = error {
                XCTAssertTrue(underlyingError is URLError)
            } else {
                XCTFail("Expected network error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Request Building Tests
    
    func testRequestBuilding() async throws {
        // Given
        struct TestBody: Codable {
            let name: String
            let value: Int
        }
        
        let testBody = TestBody(name: "test", value: 42)
        let endpoint = APIEndpoint(
            baseURL: "https://api.example.com",
            path: "users/123",
            method: .POST,
            headers: [
                "Authorization": "Bearer token123",
                "Custom-Header": "custom-value"
            ],
            body: testBody,
            timeout: 60.0
        )
        
        // Mock a successful response to avoid the actual request
        let response = HTTPURLResponse(
            url: URL(string: "https://api.example.com/users/123")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        mockURLSession.mockResponse = (Data("{}".utf8), response)
        
        // When
        _ = try await networkManager.request(endpoint, responseType: User.self)
        
        // Then - verify the request was built correctly
        XCTAssertNotNil(mockURLSession.lastRequest)
        let request = mockURLSession.lastRequest!
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/users/123")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.timeoutInterval, 60.0)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token123")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Custom-Header"), "custom-value")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.httpBody)
    }
    
    // MARK: - Upload Tests
    
    func testFileUpload() async throws {
        // Given
        let uploadData = "test file content".data(using: .utf8)!
        let expectedResponse = FileUploadResponse(
            id: "file123",
            uuid: "uuid123",
            displayName: "test.txt",
            filename: "test.txt",
            contentType: "text/plain",
            url: "https://example.com/files/test.txt",
            size: uploadData.count,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let responseData = try JSONEncoder().encode(expectedResponse)
        let response = HTTPURLResponse(
            url: URL(string: "https://test.com/upload")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockResponse = (responseData, response)
        
        let endpoint = APIEndpoint(
            baseURL: "https://test.com",
            path: "upload",
            method: .POST
        )
        
        // When
        let result = try await networkManager.upload(
            endpoint,
            data: uploadData,
            responseType: FileUploadResponse.self
        )
        
        // Then
        XCTAssertEqual(result.id, expectedResponse.id)
        XCTAssertEqual(result.filename, expectedResponse.filename)
        XCTAssertEqual(result.size, expectedResponse.size)
    }
}

// MARK: - NetworkError Equatable Extension

extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.rateLimited, .rateLimited):
            return true
        case (.badRequest(let lhsMessage), .badRequest(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.unknownError(let lhsCode), .unknownError(let rhsCode)):
            return lhsCode == rhsCode
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - APIErrorResponse Test Extension

extension APIErrorResponse {
    init(message: String, errors: [String]?) {
        self.message = message
        self.errors = errors
    }
}