import Foundation

/// Protocol defining the authentication service interface
protocol AuthenticationProtocol {
    /// Current authentication state
    var isAuthenticated: Bool { get }
    
    /// Current authenticated user
    var currentUser: User? { get }
    
    /// Authenticate with Canvas using base URL and API token
    func authenticate(baseURL: String, apiToken: String) async throws
    
    /// Logout and clear stored credentials
    func logout() async throws
    
    /// Validate stored API token
    func validateStoredToken() async throws -> Bool
    
    /// Get stored API token
    func getStoredToken() throws -> String?
    
    /// Get stored base URL
    func getStoredBaseURL() throws -> String?
}