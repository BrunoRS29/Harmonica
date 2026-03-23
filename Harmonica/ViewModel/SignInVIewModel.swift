import Foundation
import Combine

@MainActor
class SignInViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var nome: String = ""
    @Published var senha: String = ""
    @Published var confirmarSenha: String = ""
    @Published var isLoading: Bool = false
    @Published var mensagemErro: String?
    @Published var cadastroSucesso: Bool = false
    
    func Cadastrar(userSession: UserSession) {
        guard validarCampos() else { return }
        
        isLoading = true
        mensagemErro = nil
        
        Task {
            do {
                try userSession.cadastrar(email: email, senha: senha, nome: nome)
                
                cadastroSucesso = true
                print("✅ Cadastro realizado com sucesso!")
                
            } catch AuthError.usuarioJaExiste {
                mensagemErro = "Este email já está cadastrado. Faça login."
            } catch {
                mensagemErro = "Erro ao criar conta: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    private func validarCampos() -> Bool {
        guard !email.isEmpty else {
            mensagemErro = "Por favor, insira seu email"
            return false
        }
        
        guard !nome.isEmpty else {
            mensagemErro = "Por favor, insira seu nome"
            return false
        }
        
        guard email.contains("@") else {
            mensagemErro = "Email inválido"
            return false
        }
        
        guard !senha.isEmpty else {
            mensagemErro = "Por favor, insira uma senha"
            return false
        }
        
        guard senha.count >= 6 else {
            mensagemErro = "A senha deve ter no mínimo 6 caracteres"
            return false
        }
        
        guard senha == confirmarSenha else {
            mensagemErro = "As senhas não coincidem"
            return false
        }
        
        return true
    }
}

enum SignInError: LocalizedError {
    case usuarioJaExiste
    
    var errorDescription: String? {
        switch self {
        case .usuarioJaExiste:
            return "Usuário já existe"
        }
    }
}
