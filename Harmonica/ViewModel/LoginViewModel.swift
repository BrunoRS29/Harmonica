import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var senha: String = ""
    @Published var lembreSenha: Bool = false
    @Published var isLoading: Bool = false
    @Published var mensagemErro: String?
    @Published var loginSucesso: Bool = false
    @Published var navegarParaCadastro: Bool = false
    
    func fazerLogin(userSession: UserSession) {
        guard validarCampos() else { return }
        
        isLoading = true
        mensagemErro = nil
        
        Task {
            do {
                // ✅ Faz login através do UserSession
                try userSession.login(email: email, senha: senha)
                
                // Salva preferência de lembrar senha
                userSession.atualizarLembrarSenha(lembrar: lembreSenha)
                
                loginSucesso = true
                print("✅ Login realizado com sucesso!")
                
            } catch AuthError.usuarioNaoEncontrado {
                mensagemErro = "Usuário não encontrado. Faça o cadastro primeiro."
            } catch AuthError.senhaIncorreta {
                mensagemErro = "Senha incorreta. Tente novamente."
            } catch {
                mensagemErro = "Erro ao fazer login: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func carregarCredenciais(email: String) {
        self.email = email
        
        let deveLembrarSenha = KeychainHelper.shouldRememberPassword(for: email)
        
        if deveLembrarSenha {
            if let senhaSalva = try? KeychainHelper.get(email: email) {
                self.senha = senhaSalva
                self.lembreSenha = true
            }
        } else {
            self.senha = ""
            self.lembreSenha = false
        }
    }
    
    private func validarCampos() -> Bool {
        guard !email.isEmpty else {
            mensagemErro = "Por favor, insira seu email"
            return false
        }
        
        guard !senha.isEmpty else {
            mensagemErro = "Por favor, insira sua senha"
            return false
        }
        
        guard email.contains("@") else {
            mensagemErro = "Email inválido"
            return false
        }
        
        return true
    }
}

enum LoginError: LocalizedError {
    case usuarioNaoEncontrado
    case senhaIncorreta
    
    var errorDescription: String? {
        switch self {
        case .usuarioNaoEncontrado:
            return "Usuário não encontrado"
        case .senhaIncorreta:
            return "Senha incorreta"
        }
    }
}
