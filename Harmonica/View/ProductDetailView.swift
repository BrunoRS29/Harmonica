import SwiftUI

struct ProductDetailView: View {
    let product: ProductModel
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var favoriteVM: FavoriteViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("MainBlack").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Imagem do produto
                    GeometryReader { geometry in
                        AsyncImage(url: URL(string: product.image)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: 300)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.gray)
                                    .frame(maxWidth: .infinity)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: geometry.size.width, height: 300)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .frame(height: 300)
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Nome
                        HStack(alignment: .top) {
                            
                            Text(product.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Button {
                                favoriteVM.toggleFavorite(product: product)
                            } label: {
                                Image(systemName: favoriteVM.isFavorite(productId: product.id) ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Circle())
                            }
                        }
                        
                        // Marca e Categoria
                        HStack {
                            Label(product.brand, systemImage: "tag")
                            Spacer()
                            Label(product.category, systemImage: "folder")
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        
                        // Preço
                        Text("R$ \(formatPrice(product.price))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("MainGreen"))
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Especificações
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Especificações")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            SpecRow(title: "Cor", value: product.specs.color)
                            SpecRow(title: "Material", value: product.specs.primary_material)
                            SpecRow(title: "Peso", value: "\(product.specs.weight_kg) kg")
                            SpecRow(title: "Dimensões", value: "\(product.specs.dimensions_cm) cm")
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        
                        // Botão de adicionar ao carrinho
                        Button {
                            if cartVM.isInCart(productId: product.id) {
                                print("⚠️ Produto já está no carrinho")
                            } else {
                                cartVM.addToCart(product: product)
                            }
                        } label: {
                            HStack {
                                Image(systemName: cartVM.isInCart(productId: product.id) ? "checkmark.circle.fill" : "cart.badge.plus")
                                    .font(.title3)
                                
                                Text(cartVM.isInCart(productId: product.id) ? "Produto no Carrinho" : "Adicionar ao Carrinho")
                                    .font(.headline)
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(cartVM.isInCart(productId: product.id) ? Color.gray.opacity(0.7) : Color("MainGreen"))
                            .cornerRadius(12)
                        }
                        .disabled(cartVM.isInCart(productId: product.id))
                        .padding(.top, 20)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 100) // ← Aumentado para compensar tab bar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

// Componente auxiliar para as especificações
struct SpecRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(
            product: ProductModel(
                id: "1",
                name: "Violão Acústico",
                brand: "Yamaha",
                category: "Cordas",
                price: 1500,
                image: "https://example.com/violao.jpg",
                specs: SpecsModel(
                    color: "Natural",
                    primary_material: "Madeira",
                    weight_kg: 2.5,
                    dimensions_cm: "100x40x15"
                )
            )
        )
        .environmentObject(CartViewModel())
        .environmentObject(FavoriteViewModel())
        .preferredColorScheme(.dark)
    }
}
