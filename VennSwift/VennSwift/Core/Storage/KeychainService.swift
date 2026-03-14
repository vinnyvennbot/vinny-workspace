import Foundation
import Security

/// Secure storage for sensitive data using iOS Keychain
actor KeychainService {
    static let shared = KeychainService()
    
    private let serviceName = "co.vennapp.ios"
    
    private enum Key: String {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
    
    private init() {}
    
    // MARK: - Token Management
    
    func saveTokens(access: String, refresh: String) async {
        await save(access, for: .accessToken)
        await save(refresh, for: .refreshToken)
    }
    
    func getTokens() async -> (access: String?, refresh: String?) {
        let access = await get(.accessToken)
        let refresh = await get(.refreshToken)
        return (access, refresh)
    }
    
    func clearTokens() async {
        await delete(.accessToken)
        await delete(.refreshToken)
    }
    
    // MARK: - Generic Keychain Operations
    
    private func save(_ value: String, for key: Key) async {
        guard let data = value.data(using: .utf8) else { return }
        
        // Delete existing item first
        await delete(key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        #if DEBUG
        if status != errSecSuccess {
            print("Keychain save failed for \(key.rawValue): \(status)")
        }
        #endif
    }
    
    private func get(_ key: Key) async -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(_ key: Key) async {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Helper: Clear All
    
    func clearAll() async {
        await clearTokens()
        // Add other clearable items here as needed
    }
}
