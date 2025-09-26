import Combine
import Foundation

/// Manages user authentication with Canvas API
@MainActor
class AuthenticationManager: ObservableObject, AuthenticationProtocol {

  // MARK: - Published Properties

  @Published var isAuthenticated: Bool = false
  @Published var currentUser: User?
  @Published private(set) var isLoading: Bool = false
  @Published private(set) var errorMessage: String?

  // MARK: - Private Properties

  private let keychainManager: KeychainManager
  private let urlSession: URLSession
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Initialization

  nonisolated init(
    keychainManager: KeychainManager = KeychainManager(), urlSession: URLSession = .shared
  ) {
    self.keychainManager = keychainManager
    self.urlSession = urlSession

    // Check for existing authentication on init
    Task { @MainActor in
      await checkExistingAuthentication()
    }
  }

  // MARK: - AuthenticationProtocol Implementation

  /// Authenticate with Canvas using base URL and API token
  func authenticate(baseURL: String, apiToken: String) async throws {
    isLoading = true
    errorMessage = nil

    defer {
      isLoading = false
    }

    do {
      // Validate the provided credentials
      let user = try await validateCredentials(baseURL: baseURL, apiToken: apiToken)

      // Store credentials securely
      guard keychainManager.storeBaseURL(baseURL),
        keychainManager.storeAPIToken(apiToken)
      else {
        throw AuthenticationError.keychainStorageError
      }

      // Update authentication state
      currentUser = user
      isAuthenticated = true

    } catch {
      // Clear any partially stored credentials on error
      _ = keychainManager.clearCredentials()
      currentUser = nil
      isAuthenticated = false

      if let authError = error as? AuthenticationError {
        errorMessage = authError.localizedDescription
        throw authError
      } else {
        let authError = AuthenticationError.networkError(error)
        errorMessage = authError.localizedDescription
        throw authError
      }
    }
  }

  /// Logout and clear stored credentials
  func logout() async throws {
    isLoading = true

    defer {
      isLoading = false
    }

    // Clear stored credentials
    guard keychainManager.clearCredentials() else {
      throw AuthenticationError.keychainStorageError
    }

    // Update authentication state
    currentUser = nil
    isAuthenticated = false
    errorMessage = nil
  }

  /// Test network connectivity
  func testNetworkConnectivity() async -> Bool {
    do {
      let url = URL(string: "https://httpbin.org/get")!
      let (_, response) = try await urlSession.data(from: url)
      if let httpResponse = response as? HTTPURLResponse {
        print("🌐 Network test successful: \(httpResponse.statusCode)")
        return httpResponse.statusCode == 200
      }
    } catch {
      print("🌐 Network test failed: \(error)")
    }
    return false
  }

  /// Validate stored API token
  func validateStoredToken() async throws -> Bool {
    guard let baseURL = keychainManager.getBaseURL(),
      let apiToken = keychainManager.getAPIToken()
    else {
      return false
    }

    do {
      let user = try await validateCredentials(baseURL: baseURL, apiToken: apiToken)
      currentUser = user
      isAuthenticated = true
      return true
    } catch {
      // Clear invalid credentials
      _ = keychainManager.clearCredentials()
      currentUser = nil
      isAuthenticated = false
      return false
    }
  }

  /// Get stored API token
  func getStoredToken() throws -> String? {
    return keychainManager.getAPIToken()
  }

  /// Get stored base URL
  func getStoredBaseURL() throws -> String? {
    return keychainManager.getBaseURL()
  }

  // MARK: - Private Methods

  /// Check for existing authentication on app launch
  private func checkExistingAuthentication() async {
    do {
      _ = try await validateStoredToken()
    } catch {
      // Silently fail - user will need to authenticate
    }
  }

  /// Validate credentials by making a test API call
  private func validateCredentials(baseURL: String, apiToken: String) async throws -> User {
    // Ensure the base URL is properly formatted
    let formattedURL = formatBaseURL(baseURL)

    // Create the API endpoint URL for user profile
    guard let url = URL(string: "\(formattedURL)/api/v1/users/self") else {
      throw AuthenticationError.invalidURL
    }

    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    // Make the API call
    do {
      let (data, response) = try await urlSession.data(for: request)

      // Check HTTP response status
      guard let httpResponse = response as? HTTPURLResponse else {
        throw AuthenticationError.invalidResponse
      }

      switch httpResponse.statusCode {
      case 200:
        // Success - decode user data
        do {
          let user = try JSONDecoder().decode(User.self, from: data)
          return user
        } catch {
          throw AuthenticationError.invalidUserData
        }
      case 401:
        throw AuthenticationError.invalidCredentials
      case 403:
        throw AuthenticationError.insufficientPermissions
      case 404:
        throw AuthenticationError.invalidURL
      default:
        throw AuthenticationError.serverError(httpResponse.statusCode)
      }

    } catch let error as AuthenticationError {
      throw error
    } catch {
      throw AuthenticationError.networkError(error)
    }
  }

  /// Format the base URL to ensure it's properly structured
  private func formatBaseURL(_ baseURL: String) -> String {
    var formatted = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)

    // Add https:// if no scheme is provided
    if !formatted.hasPrefix("http://") && !formatted.hasPrefix("https://") {
      formatted = "https://" + formatted
    }

    // Remove trailing slash
    if formatted.hasSuffix("/") {
      formatted = String(formatted.dropLast())
    }

    return formatted
  }
}

// MARK: - AuthenticationError

enum AuthenticationError: LocalizedError {
  case invalidURL
  case invalidCredentials
  case insufficientPermissions
  case invalidUserData
  case keychainStorageError
  case networkError(Error)
  case serverError(Int)
  case invalidResponse

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid Canvas URL. Please check the URL and try again."
    case .invalidCredentials:
      return "Invalid API token. Please check your token and try again."
    case .insufficientPermissions:
      return "Insufficient permissions. Please ensure your API token has the required permissions."
    case .invalidUserData:
      return "Unable to retrieve user information. Please try again."
    case .keychainStorageError:
      return "Unable to securely store credentials. Please try again."
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    case .serverError(let statusCode):
      return "Server error (HTTP \(statusCode)). Please try again later."
    case .invalidResponse:
      return "Invalid response from server. Please try again."
    }
  }

  var recoverySuggestion: String? {
    switch self {
    case .invalidURL:
      return "Ensure the Canvas URL is in the format: https://yourschool.instructure.com"
    case .invalidCredentials:
      return "Generate a new API token from your Canvas account settings."
    case .insufficientPermissions:
      return "Contact your Canvas administrator for proper API access."
    case .invalidUserData, .invalidResponse:
      return "Check your internet connection and try again."
    case .keychainStorageError:
      return "Restart the app and try again."
    case .networkError:
      return "Check your internet connection and try again."
    case .serverError:
      return "Wait a moment and try again. If the problem persists, contact support."
    }
  }
}
