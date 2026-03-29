import Foundation
@testable import Harmonica

class MockUserSession: UserSession {
    
    var shouldFailLogin = false
    var shouldFailCadastro = false
    var errorToThrow: Error = AuthError.usuarioNaoEncontrado
    
    var loginCallCount = 0
    var cadastrarCallCount = 0
    var atualizarLembrarSenhaCallCount = 0
    
    var lastLembrarSenhaValue: Bool?
    var lastCadastroEmail: String?
    var lastCadastroNome: String?
    
    override func login(email: String, senha: String?) throws {
        loginCallCount += 1
        
        if shouldFailLogin {
            throw errorToThrow
        }
        
        usuarioAtual = User(
            id: "mock-id",
            email: email,
            nome: "Mock User"
        )
    }
    
    override func cadastrar(email: String, senha: String?, nome: String?) throws {
        cadastrarCallCount += 1
        lastCadastroEmail = email
        lastCadastroNome = nome
        
        if shouldFailCadastro {
            throw errorToThrow
        }
        
        usuarioAtual = User(
            id: "mock-id-\(email)",
            email: email,
            nome: nome
        )
    }
    
    override func atualizarLembrarSenha(lembrar: Bool) {
        atualizarLembrarSenhaCallCount += 1
        lastLembrarSenhaValue = lembrar
    }
}
