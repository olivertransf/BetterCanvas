import Foundation
import Security

/// Manages secure storage of authentication credentials in iOS Keychain
class KeychainManager {
    
    // MARK: - Constants
    
    private enum Keys {
        static let apiToken = "canvas_api_token"
        static let baseURL = "canvas_base_url"
        static let service = "BetterCanvas"
    }
    
    // MARK: - Singleton
    
    static let shared = KeychainManager()
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    /// Stores the API token securely in the keychain
    /// - Parameter token: The Canvas API token to store
    /// - Returns: True if storage was successful, false otherwise
    func storeAPIToken(_ token: String) -> Bool {
        return storeValue(token, forKey: Keys.apiToken)
    }
    
    /// Retrieves the stored API token from the keychain
    /// - Returns: The stored API token, or nil if not found
    func getAPIToken() -> String? {
        return getValue(forKey: Keys.apiToken)
    }
    
    /// Stores the Canvas base URL securely in the keychain
    /// - Parameter baseURL: The Canvas instance base URL to store
    /// - Returns: True if storage was successful, false otherwise
    func storeBaseURL(_ baseURL: String) -> Bool {
        return storeValue(baseURL, forKey: Keys.baseURL)
    }
    
    /// Retrieves the stored Canvas base URL from the keychain
    /// - Returns: The stored base URL, or nil if not found
    func getBaseURL() -> String? {
        return getValue(forKey: Keys.baseURL)
    }
    
    /// Removes all stored authentication credentials from the keychain
    /// - Returns: True if deletion was successful, false otherwise
    func clearCredentials() -> Bool {
        let tokenDeleted = deleteValue(forKey: Keys.apiToken)
        let urlDeleted = deleteValue(forKey: Keys.baseURL)
        return tokenDeleted && urlDeleted
    }
    
    // MARK: - Private Methods
    
    /// Stores a string value in the keychain
    /// - Parameters:
    ///   - value: The string value to store
    ///   - key: The key to associate with the value
    /// - Returns: True if storage was successful, false otherwise
    private func storeValue(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // First, delete any existing item
        _ = deleteValue(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieves a string value from the keychain
    /// - Parameter key: The key associated with the value
    /// - Returns: The stored string value, or nil if not found
    private func getValue(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    /// Deletes a value from the keychain
    /// - Parameter key: The key associated with the value to delete
    /// - Returns: True if deletion was successful, false otherwise
    private func deleteValue(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Keys.service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}