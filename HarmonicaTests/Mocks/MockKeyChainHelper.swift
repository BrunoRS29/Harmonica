import Foundation
@testable import Harmonica

class MockKeychainHelper: KeychainHelperProtocol {
    
    private static var storage: [String: String] = [:]
    private static var rememberFlags: [String: Bool] = [:]
    
    static var saveCallCount = 0
    static var getCallCount = 0
    
    static func save(email: String, senha: String) throws {
        saveCallCount += 1
        storage[email] = senha
    }
    
    static func get(email: String) throws -> String? {
        getCallCount += 1
        return storage[email]
    }
    
    static func delete(email: String) throws {
        storage.removeValue(forKey: email)
        rememberFlags.removeValue(forKey: email)
    }
    
    static func shouldRememberPassword(for email: String) -> Bool {
        return rememberFlags[email] ?? false
    }
    
    static func saveRememberPassword(for email: String, remember: Bool) throws {
        rememberFlags[email] = remember
    }
    
    // Helper para limpar entre testes
    static func reset() {
        storage.removeAll()
        rememberFlags.removeAll()
        saveCallCount = 0
        getCallCount = 0
    }
}
