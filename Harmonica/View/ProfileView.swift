import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var cartVM: CartViewModel
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MainBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header com avatar e nome
                        VStack(spacing: 12) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color("MainGreen").opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Text(getInitials())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(Color("MainGreen"))
                            }
                            
                            // Nome
                            Text(userSession.usuarioAtual?.nome ?? "Usuário")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Email
                            Text(userSession.usuarioAtual?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        .padding(.horizontal)
                        
                        // Seção de Favoritos
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color("MainGreen"))
                                Text("Itens Favoritos")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Lista vazia (você pode integrar com favoritos depois)
                            VStack(spacing: 12) {
                                Image(systemName: "heart.slash")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.3))
                                
                                Text("Nenhum item favoritado")
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("Adicione produtos aos favoritos para vê-los aqui")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Opções
                        VStack(spacing: 12) {
                            
                            // Minha Conta
                            ProfileOptionRow(
                                icon: "person.fill",
                                title: "Minha Conta",
                                color: .blue
                            ) {
                                print("Minha conta")
                            }
                            
                            // Pedidos
                            ProfileOptionRow(
                                icon: "shippingbox.fill",
                                title: "Meus Pedidos",
                                color: .orange
                            ) {
                                print("Meus pedidos")
                            }
                            
                            // Configurações
                            ProfileOptionRow(
                                icon: "gearshape.fill",
                                title: "Configurações",
                                color: .gray
                            ) {
                                print("Configurações")
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.vertical, 8)
                            
                            // Deletar Conta
                            ProfileOptionRow(
                                icon: "trash.fill",
                                title: "Deletar Conta",
                                color: .orange,
                                showArrow: false
                            ) {
                                showDeleteAccountAlert = true
                            }
                            
                            // Logout
                            ProfileOptionRow(
                                icon: "rectangle.portrait.and.arrow.right",
                                title: "Sair",
                                color: .red,
                                showArrow: false
                            ) {
                                showLogoutAlert = true
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            
            // Alert de Logout
            .alert("Sair da conta", isPresented: $showLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Sair", role: .destructive) {
                    userSession.logout()
                }
            } message: {
                Text("Tem certeza que deseja sair?")
            }
            
            // Alert de Deletar Conta
            .alert("Deletar Conta", isPresented: $showDeleteAccountAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Deletar", role: .destructive) {
                    do {
                        try userSession.deletarConta()
                    } catch {
                        print("❌ Erro ao deletar conta: \(error)")
                    }
                }
            } message: {
                Text("Esta ação é irreversível. Todos os seus dados serão perdidos.")
            }
        }
    }
    
    // Pega as iniciais do nome
    private func getInitials() -> String {
        guard let name = userSession.usuarioAtual?.nome else { return "?" }
        let components = name.split(separator: " ")
        
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(1)).uppercased()
        }
        
        return "?"
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("MainGreen"))
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}

// MARK: - Profile Option Row
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    var showArrow: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserSession())
        .environmentObject(CartViewModel())
}
