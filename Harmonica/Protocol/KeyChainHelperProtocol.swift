import Foundation

protocol KeychainHelperProtocol {
    static func save(email: String, senha: String) throws
    static func get(email: String) throws -> String?
    static func delete(email: String) throws
    static func shouldRememberPassword(for email: String) -> Bool
    static func saveRememberPassword(for email: String, remember: Bool) throws
}

extension KeychainHelper: KeychainHelperProtocol {}
