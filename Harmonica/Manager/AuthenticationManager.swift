//import SwiftUI
//import Combine
//
//@MainActor
//class AuthenticationManager: ObservableObject {
//    @Published var isAuthenticated = false
//    @Published var isLoading = true
//    
//    init() {
//        verificarAutenticacao()
//    }
//    
//    func verificarAutenticacao() {
//        isLoading = true
//        
//        if let ultimoEmail = KeychainHelper.getLastEmail() {
//            do {
//                if let _ = try KeychainHelper.get(email: ultimoEmail) {
//                    isAuthenticated = true
//                }
//            } catch {
//                print("Erro ao verificar credenciais: \(error)")
//            }
//        }
//        
//        isLoading = false
//    }
//    
//    func login(email: String) {
//        try? KeychainHelper.saveLastEmail(email)
//        isAuthenticated = true
//    }
//    
//    func logout() {
//        if let email = KeychainHelper.getLastEmail() {
//            try? KeychainHelper.delete(email: email)
//            try? KeychainHelper.saveRememberPassword(for: email, remember: false)
//        }
//        
//        isAuthenticated = false
//    }
//}
