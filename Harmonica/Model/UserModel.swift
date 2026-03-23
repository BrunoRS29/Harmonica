import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var nome: String?
    let dataCriacao: Date
    
    init(id: String = UUID().uuidString, email: String, nome: String? = nil) {
        self.id = id
        self.email = email
        self.nome = nome
        self.dataCriacao = Date()
    }
}
