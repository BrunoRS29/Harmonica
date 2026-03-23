import SwiftUI
import Combine

@MainActor
class UserSession: ObservableObject {
    @Published var usuarioAtual: User?
    @Published var isAuthenticated = false
    @Published var isLoading = true
    
    init() {
        verificarSessao()
    }
    
    func verificarSessao() {
        isLoading = true
        
        if let ultimoEmail = KeychainHelper.getLastEmail() {
            if KeychainHelper.shouldRememberPassword(for: ultimoEmail),
               let usuario = KeychainHelper.getUser(email: ultimoEmail),
               let _ = try? KeychainHelper.get(email: ultimoEmail) {
                self.usuarioAtual = usuario
                self.isAuthenticated = true
                print("✅ Sessão restaurada para: \(usuario.email)")
            }
        }
        
        isLoading = false
    }
    
    func login(email: String, senha: String) throws {
        // Verifica credenciais
        guard let senhaSalva = try? KeychainHelper.get(email: email) else {
            throw AuthError.usuarioNaoEncontrado
        }
        
        guard senhaSalva == senha else {
            throw AuthError.senhaIncorreta
        }
        
        // Carrega dados do usuário
        guard let usuario = KeychainHelper.getUser(email: email) else {
            throw AuthError.usuarioNaoEncontrado
        }
        
        // Salva como último email
        try? KeychainHelper.saveLastEmail(email)
        
        self.usuarioAtual = usuario
        self.isAuthenticated = true
        
        print("✅ Login efetuado: \(usuario.email)")
    }
    
    func cadastrar(email: String, senha: String, nome: String? = nil) throws {
        // Verifica se usuário já existe
        if let _ = try? KeychainHelper.get(email: email) {
            throw AuthError.usuarioJaExiste
        }
        
        // Cria novo usuário
        let novoUsuario = User(email: email, nome: nome)
        
        // Salva senha no Keychain
        try KeychainHelper.save(email: email, senha: senha)
        
        // Salva dados do usuário
        try KeychainHelper.saveUser(novoUsuario)
        
        // Salva como último email (mas sem lembrar senha)
        try KeychainHelper.saveLastEmail(email)
        try KeychainHelper.saveRememberPassword(for: email, remember: false)
        
        print("✅ Usuário cadastrado: \(email)")
    }
    
    func atualizarLembrarSenha(lembrar: Bool) {
        guard let email = usuarioAtual?.email else { return }
        try? KeychainHelper.saveRememberPassword(for: email, remember: lembrar)
    }
    
    func logout() {
        guard let usuario = usuarioAtual else { return }
        
        // NÃO deleta as credenciais, apenas desmarca "lembrar senha"
        try? KeychainHelper.saveRememberPassword(for: usuario.email, remember: false)
        
        self.usuarioAtual = nil
        self.isAuthenticated = false
        
        print("✅ Logout efetuado: \(usuario.email)")
    }
    
    func deletarConta() throws {
        guard let usuario = usuarioAtual else { return }
        
        // Remove senha
        try KeychainHelper.delete(email: usuario.email)
        
        // Remove preferência
        try KeychainHelper.deleteRememberPassword(for: usuario.email)
        
        // Remove dados do usuário
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "user_\(usuario.email)"
        ]
        SecItemDelete(query as CFDictionary)
        
        self.usuarioAtual = nil
        self.isAuthenticated = false
        
        print("✅ Conta deletada: \(usuario.email)")
    }
}

enum AuthError: LocalizedError {
    case usuarioNaoEncontrado
    case senhaIncorreta
    case usuarioJaExiste
    
    var errorDescription: String? {
        switch self {
        case .usuarioNaoEncontrado:
            return "Usuário não encontrado"
        case .senhaIncorreta:
            return "Senha incorreta"
        case .usuarioJaExiste:
            return "Este email já está cadastrado"
        }
    }
}
