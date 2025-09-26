import XCTest
import Combine
@testable import BetterCanvas

final class AuthenticationManagerTests: XCTestCase {
    
    var authManager: AuthenticationManager!
    var mockKeychainManager: MockKeychainManager!
    var mockURLSession: MockURLSession!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockKeychainManager = MockKeychainManager()
        mockURLSession = MockURLSession()
        cancellables = Set<AnyCancellable>()
        
        authManager = AuthenticationManager(
            keychainManager: mockKeychainManager,
            urlSession: mockURLSession
        )
    }
    
    override func tearDown() {
        authManager = nil
        mockKeychainManager = nil
        mockURLSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Tests
    
    @MainActor
    func testSuccessfulAuthentication() async throws {
        // Given
        let baseURL = "https://test.instructure.com"
        let apiToken = "test_token_123"
        let expectedUser = User(id: "123", name: "Test User", email: "test@example.com", avatarURL: nil)
        
        mockURLSession.mockResponse = createSuccessResponse(user: expectedUser)
        mockKeychainManager.shouldSucceed = true
        
        // When
        try await authManager.authenticate(baseURL: baseURL, apiToken: apiToken)
        
        // Then
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertEqual(authManager.currentUser?.id, expectedUser.id)
        XCTAssertEqual(authManager.currentUser?.name, expectedUser.name)
        XCTAssertFalse(authManager.isLoading)
        XCTAssertNil(authManager.errorMessage)
        
        // Verify credentials were stored
        XCTAssertTrue(mockKeychainManager.storeBaseURLCalled)
        XCTAssertTrue(mockKeychainManager.storeAPITokenCalled)
        XCTAssertEqual(mockKeychainManager.storedBaseURL, baseURL)
        XCTAssertEqual(mockKeychainManager.storedAPIToken, apiToken)
    }
    
    @MainActor
    func testAuthenticationWithInvalidCredentials() async {
        // Given
        let baseURL = "https://test.instructure.com"
        let apiToken = "invalid_token"
        
        mockURLSession.mockResponse = createErrorResponse(statusCode: 401)
        
        // When/Then
        do {
            try await authManager.authenticate(baseURL: baseURL, apiToken: apiToken)
            XCTFail("Expected authentication to fail")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidCredentials)
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertNil(authManager.currentUser)
            XCTAssertNotNil(authManager.errorMessage)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    @MainActor
    func testAuthenticationWithInvalidURL() async {
        // Given
        let baseURL = "invalid-url"
        let apiToken = "test_token"
        
        // When/Then
        do {
            try await authManager.authenticate(baseURL: baseURL, apiToken: apiToken)
            XCTFail("Expected authentication to fail")
        } catch let error as AuthenticationError {
            // The URL formatting should handle this, but if it still fails, it should be a network error
            XCTAssertTrue(error.localizedDescription.contains("error") || error.localizedDescription.contains("Invalid"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    @MainActor
    func testAuthenticationWithKeychainFailure() async {
        // Given
        let baseURL = "https://test.instructure.com"
        let apiToken = "test_token"
        let expectedUser = User(id: "123", name: "Test User", email: "test@example.com", avatarURL: nil)
        
        mockURLSession.mockResponse = createSuccessResponse(user: expectedUser)
        mockKeychainManager.shouldSucceed = false // Keychain will fail
        
        // When/Then
        do {
            try await authManager.authenticate(baseURL: baseURL, apiToken: apiToken)
            XCTFail("Expected authentication to fail due to keychain error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .keychainStorageError)
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertNil(authManager.currentUser)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Logout Tests
    
    @MainActor
    func testSuccessfulLogout() async throws {
        // Given - Set up authenticated state
        authManager.currentUser = User(id: "123", name: "Test User", email: "test@example.com", avatarURL: nil)
        authManager.isAuthenticated = true
        mockKeychainManager.shouldSucceed = true
        
        // When
        try await authManager.logout()
        
        // Then
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.currentUser)
        XCTAssertFalse(authManager.isLoading)
        XCTAssertNil(authManager.errorMessage)
        XCTAssertTrue(mockKeychainManager.clearCredentialsCalled)
    }
    
    @MainActor
    func testLogoutWithKeychainFailure() async {
        // Given
        mockKeychainManager.shouldSucceed = false
        
        // When/Then
        do {
            try await authManager.logout()
            XCTFail("Expected logout to fail due to keychain error")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .keychainStorageError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Token Validation Tests
    
    @MainActor
    func testValidateStoredTokenSuccess() async throws {
        // Given
        let expectedUser = User(id: "123", name: "Test User", email: "test@example.com", avatarURL: nil)
        mockKeychainManager.storedBaseURL = "https://test.instructure.com"
        mockKeychainManager.storedAPIToken = "valid_token"
        mockURLSession.mockResponse = createSuccessResponse(user: expectedUser)
        
        // When
        let isValid = try await authManager.validateStoredToken()
        
        // Then
        XCTAssertTrue(isValid)
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertEqual(authManager.currentUser?.id, expectedUser.id)
    }
    
    @MainActor
    func testValidateStoredTokenWithNoStoredCredentials() async throws {
        // Given
        mockKeychainManager.storedBaseURL = nil
        mockKeychainManager.storedAPIToken = nil
        
        // When
        let isValid = try await authManager.validateStoredToken()
        
        // Then
        XCTAssertFalse(isValid)
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.currentUser)
    }
    
    @MainActor
    func testValidateStoredTokenWithInvalidCredentials() async throws {
        // Given
        mockKeychainManager.storedBaseURL = "https://test.instructure.com"
        mockKeychainManager.storedAPIToken = "invalid_token"
        mockURLSession.mockResponse = createErrorResponse(statusCode: 401)
        
        // When
        let isValid = try await authManager.validateStoredToken()
        
        // Then
        XCTAssertFalse(isValid)
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertNil(authManager.currentUser)
        XCTAssertTrue(mockKeychainManager.clearCredentialsCalled)
    }
    
    // MARK: - Credential Access Tests
    
    func testGetStoredToken() throws {
        // Given
        let expectedToken = "stored_token_123"
        mockKeychainManager.storedAPIToken = expectedToken
        
        // When
        let token = try authManager.getStoredToken()
        
        // Then
        XCTAssertEqual(token, expectedToken)
    }
    
    func testGetStoredBaseURL() throws {
        // Given
        let expectedURL = "https://stored.instructure.com"
        mockKeychainManager.storedBaseURL = expectedURL
        
        // When
        let url = try authManager.getStoredBaseURL()
        
        // Then
        XCTAssertEqual(url, expectedURL)
    }
    
    // MARK: - Helper Methods
    
    private func createSuccessResponse(user: User) -> (Data, URLResponse) {
        let userData = try! JSONEncoder().encode(user)
        let response = HTTPURLResponse(
            url: URL(string: "https://test.instructure.com/api/v1/users/self")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (userData, response)
    }
    
    private func createErrorResponse(statusCode: Int) -> (Data, URLResponse) {
        let errorData = Data()
        let response = HTTPURLResponse(
            url: URL(string: "https://test.instructure.com/api/v1/users/self")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (errorData, response)
    }
}

// MARK: - Mock Classes

class MockKeychainManager: KeychainManager {
    var shouldSucceed = true
    var storedAPIToken: String?
    var storedBaseURL: String?
    
    var storeAPITokenCalled = false
    var storeBaseURLCalled = false
    var clearCredentialsCalled = false
    
    override func storeAPIToken(_ token: String) -> Bool {
        storeAPITokenCalled = true
        if shouldSucceed {
            storedAPIToken = token
        }
        return shouldSucceed
    }
    
    override func getAPIToken() -> String? {
        return storedAPIToken
    }
    
    override func storeBaseURL(_ baseURL: String) -> Bool {
        storeBaseURLCalled = true
        if shouldSucceed {
            storedBaseURL = baseURL
        }
        return shouldSucceed
    }
    
    override func getBaseURL() -> String? {
        return storedBaseURL
    }
    
    override func clearCredentials() -> Bool {
        clearCredentialsCalled = true
        if shouldSucceed {
            storedAPIToken = nil
            storedBaseURL = nil
        }
        return shouldSucceed
    }
}

class MockURLSession: URLSession {
    var mockResponse: (Data, URLResponse)?
    var mockError: Error?
    var lastRequest: URLRequest?
    
    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        
        return response
    }
    
    override func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        lastRequest = request
        
        if let error = mockError {
            throw error
        }
        
        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        
        return response
    }
}