import XCTest
@testable import BetterCanvas

final class KeychainManagerTests: XCTestCase {
    
    var keychainManager: KeychainManager!
    
    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager.shared
        // Clear any existing test data
        _ = keychainManager.clearCredentials()
    }
    
    override func tearDown() {
        // Clean up after each test
        _ = keychainManager.clearCredentials()
        keychainManager = nil
        super.tearDown()
    }
    
    // MARK: - API Token Tests
    
    func testStoreAndRetrieveAPIToken() {
        // Given
        let testToken = "test_api_token_12345"
        
        // When
        let storeResult = keychainManager.storeAPIToken(testToken)
        let retrievedToken = keychainManager.getAPIToken()
        
        // Then
        XCTAssertTrue(storeResult, "API token should be stored successfully")
        XCTAssertEqual(retrievedToken, testToken, "Retrieved token should match stored token")
    }
    
    func testStoreEmptyAPIToken() {
        // Given
        let emptyToken = ""
        
        // When
        let storeResult = keychainManager.storeAPIToken(emptyToken)
        let retrievedToken = keychainManager.getAPIToken()
        
        // Then
        XCTAssertTrue(storeResult, "Empty token should be stored successfully")
        XCTAssertEqual(retrievedToken, emptyToken, "Retrieved token should be empty string")
    }
    
    func testRetrieveNonExistentAPIToken() {
        // When
        let retrievedToken = keychainManager.getAPIToken()
        
        // Then
        XCTAssertNil(retrievedToken, "Non-existent token should return nil")
    }
    
    func testOverwriteAPIToken() {
        // Given
        let firstToken = "first_token"
        let secondToken = "second_token"
        
        // When
        _ = keychainManager.storeAPIToken(firstToken)
        let storeResult = keychainManager.storeAPIToken(secondToken)
        let retrievedToken = keychainManager.getAPIToken()
        
        // Then
        XCTAssertTrue(storeResult, "Second token should be stored successfully")
        XCTAssertEqual(retrievedToken, secondToken, "Retrieved token should be the second token")
    }
    
    // MARK: - Base URL Tests
    
    func testStoreAndRetrieveBaseURL() {
        // Given
        let testURL = "https://canvas.instructure.com"
        
        // When
        let storeResult = keychainManager.storeBaseURL(testURL)
        let retrievedURL = keychainManager.getBaseURL()
        
        // Then
        XCTAssertTrue(storeResult, "Base URL should be stored successfully")
        XCTAssertEqual(retrievedURL, testURL, "Retrieved URL should match stored URL")
    }
    
    func testStoreComplexBaseURL() {
        // Given
        let complexURL = "https://myschool.instructure.com/api/v1"
        
        // When
        let storeResult = keychainManager.storeBaseURL(complexURL)
        let retrievedURL = keychainManager.getBaseURL()
        
        // Then
        XCTAssertTrue(storeResult, "Complex URL should be stored successfully")
        XCTAssertEqual(retrievedURL, complexURL, "Retrieved URL should match stored complex URL")
    }
    
    func testRetrieveNonExistentBaseURL() {
        // When
        let retrievedURL = keychainManager.getBaseURL()
        
        // Then
        XCTAssertNil(retrievedURL, "Non-existent URL should return nil")
    }
    
    // MARK: - Clear Credentials Tests
    
    func testClearCredentials() {
        // Given
        let testToken = "test_token"
        let testURL = "https://test.canvas.com"
        
        // When
        _ = keychainManager.storeAPIToken(testToken)
        _ = keychainManager.storeBaseURL(testURL)
        let clearResult = keychainManager.clearCredentials()
        
        // Then
        XCTAssertTrue(clearResult, "Credentials should be cleared successfully")
        XCTAssertNil(keychainManager.getAPIToken(), "API token should be nil after clearing")
        XCTAssertNil(keychainManager.getBaseURL(), "Base URL should be nil after clearing")
    }
    
    func testClearCredentialsWhenEmpty() {
        // When
        let clearResult = keychainManager.clearCredentials()
        
        // Then
        XCTAssertTrue(clearResult, "Clearing empty credentials should succeed")
    }
    
    // MARK: - Integration Tests
    
    func testStoreMultipleCredentials() {
        // Given
        let testToken = "integration_test_token"
        let testURL = "https://integration.canvas.com"
        
        // When
        let tokenStored = keychainManager.storeAPIToken(testToken)
        let urlStored = keychainManager.storeBaseURL(testURL)
        
        let retrievedToken = keychainManager.getAPIToken()
        let retrievedURL = keychainManager.getBaseURL()
        
        // Then
        XCTAssertTrue(tokenStored, "Token should be stored successfully")
        XCTAssertTrue(urlStored, "URL should be stored successfully")
        XCTAssertEqual(retrievedToken, testToken, "Retrieved token should match")
        XCTAssertEqual(retrievedURL, testURL, "Retrieved URL should match")
    }
    
    func testCredentialPersistenceAcrossInstances() {
        // Given
        let testToken = "persistence_test_token"
        
        // When
        _ = keychainManager.storeAPIToken(testToken)
        
        // Create a new instance (simulating app restart)
        let newKeychainManager = KeychainManager.shared
        let retrievedToken = newKeychainManager.getAPIToken()
        
        // Then
        XCTAssertEqual(retrievedToken, testToken, "Token should persist across instances")
    }
}