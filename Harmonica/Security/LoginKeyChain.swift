import Security
import Foundation

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case invalidData
}

class KeychainHelper {
    
    static func save(email: String, senha: String) throws {
        guard let dados = senha.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecValueData as String: dados
        ]
    
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    static func get(email: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.retrieveFailed(status)
        }
        
        guard let dados = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return String(data: dados, encoding: .utf8)
    }
    
    static func delete(email: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    static func saveLastEmail(_ email: String) throws {
        guard let emailData = email.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "lastEmail",
            kSecValueData as String: emailData
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    static func getLastEmail() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "lastEmail",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let email = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return email
    }
    
    static func saveRememberPassword(for email: String, remember: Bool) throws {
        let value = remember ? "true" : "false"
        guard let valueData = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "remember_\(email)",
            kSecValueData as String: valueData
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    static func shouldRememberPassword(for email: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "remember_\(email)",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return false
        }
        
        return value == "true"
    }
    
    static func deleteRememberPassword(for email: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "remember_\(email)"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    static func saveUser(_ usuario: User) throws {
        let encoder = JSONEncoder()
        guard let userData = try? encoder.encode(usuario) else {
            throw KeychainError.invalidData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "user_\(usuario.email)",
            kSecValueData as String: userData
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    static func getUser(email: String) -> User? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "user_\(email)",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(User.self, from: data)
    }
    
    static func deleteUser(email: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "user_\(email)"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    static func getAllUserEmails() -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { item in
            if let account = item[kSecAttrAccount as String] as? String,
               account.hasPrefix("user_") {
                return account.replacingOccurrences(of: "user_", with: "")
            }
            return nil
        }
    }
    
    static func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        SecItemDelete(query as CFDictionary)
    }
}
