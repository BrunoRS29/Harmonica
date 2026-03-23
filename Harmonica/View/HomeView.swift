import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        VStack(spacing: 20) {
            if let usuario = userSession.usuarioAtual {
                VStack(spacing: 8) {
                    Text("Bem-vindo!")
                        .font(.largeTitle)
                        .bold()
                    
                    if let nome = usuario.nome {
                        Text(nome)
                            .font(.title2)
                    }
                    
                    Text(usuario.email)
                        .font(.subheadline)
                }
                
                Spacer()
                                
                VStack(spacing: 10) {
                    Button("Sair") {
                        userSession.logout()
                    }
                    .foregroundStyle(.red)
                    
                    #if DEBUG
                    Button("🗑️ Limpar Todo Keychain (Debug)") {
                        KeychainHelper.clearAll()
                        userSession.logout()
                    }
                    .font(.caption)
                    .foregroundStyle(.orange)
                    #endif
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserSession())
}
