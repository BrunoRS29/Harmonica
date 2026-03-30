import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var favoriteVM: FavoriteViewModel
    
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MainBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            
                            ZStack {
                                Circle()
                                    .fill(Color("MainGreen").opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Text(getInitials())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(Color("MainGreen"))
                            }
                            
                            Text(userSession.usuarioAtual?.nome ?? "Usuário")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(userSession.usuarioAtual?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(Color("MainGreen"))
                                
                                Text("Itens Favoritos")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            if favoriteVM.favoriteItems.isEmpty {
                                
                                VStack(spacing: 12) {
                                    Image(systemName: "heart.slash")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.white.opacity(0.3))
                                    
                                    Text("Nenhum item favoritado")
                                        .foregroundStyle(.white.opacity(0.6))
                                    
                                    Text("Adicione produtos aos favoritos para vê-los aqui")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                            } else {
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        
                                        ForEach(favoriteVM.favoriteItems.prefix(10)) { item in
                                            FavoritePreviewCard(item: item)
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        VStack(spacing: 12) {
                            
                            ProfileOptionRow(
                                icon: "person.fill",
                                title: "Minha Conta",
                                color: Color("MainGreen")
                            ) {
                                print("Minha conta")
                            }
                            
                            ProfileOptionRow(
                                icon: "shippingbox.fill",
                                title: "Meus Pedidos",
                                color: Color("MainGreen")
                            ) {
                                print("Meus pedidos")
                            }
                            
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
                            
                            ProfileOptionRow(
                                icon: "trash.fill",
                                title: "Deletar Conta",
                                color: .gray,
                                showArrow: false
                            ) {
                                showDeleteAccountAlert = true
                            }
                            
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
            
            .alert("Sair da conta", isPresented: $showLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Sair", role: .destructive) {
                    userSession.logout()
                }
            } message: {
                Text("Tem certeza que deseja sair?")
            }
            
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
                    .foregroundStyle(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
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
        .buttonStyle(.plain)
    }
}

struct FavoritePreviewCard: View {

    let item: FavoriteItem

    private var product: ProductModel {
        ProductModel(
            id: item.id ?? "",
            name: item.name ?? "",
            brand: item.brand ?? "",
            category: item.category ?? "",
            price: Int(item.price),
            image: item.image ?? "",
            specs: SpecsModel(
                color: item.specs_color ?? "",
                primary_material: item.specs_primary_material ?? "",
                weight_kg: item.specs_weight_kg,
                dimensions_cm: item.specs_dimensions_cm ?? ""
            )
        )
    }

    var body: some View {

        NavigationLink {
            ProductDetailView(product: product)
        } label: {

            VStack(alignment: .leading, spacing: 8) {

                AsyncImage(url: URL(string: item.image ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 140, height: 120)
                .clipped()
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {

                    Text(item.name ?? "")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .frame(height: 34, alignment: .top) // altura fixa do nome

                    Text("R$ \(item.price)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color("MainGreen"))
                }
            }
            .frame(width: 140, height: 190) // tamanho fixo do card
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
