import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MainBlack").ignoresSafeArea()
                
                if cartVM.cartItems.isEmpty {
                    // Carrinho vazio
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("Seu carrinho está vazio")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Adicione produtos para começar")
                            .foregroundColor(.white.opacity(0.6))
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Continuar Comprando")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color("MainGreen"))
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    
                } else {
                    // Lista de produtos
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(cartVM.cartItems) { item in
                                    CartItemRow(item: item)
                                        .environmentObject(cartVM)
                                }
                            }
                            .padding()
                            .padding(.bottom, 120) // Espaço para o footer
                        }
                        
                        Spacer()
                    }
                    
                    // Footer fixo com total e botão
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            // Total
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(cartVM.formattedTotalPrice)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("MainGreen"))
                                }
                                
                                Spacer()
                                
                                Button {
                                    // Ação de finalizar compra
                                    print("Finalizar compra")
                                } label: {
                                    Text("Finalizar Compra")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color("MainGreen"))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .background(Color("MainBlack"))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
                    }
                }
            }
            .navigationTitle("Carrinho")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                if !cartVM.cartItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            cartVM.clearCart()
                        } label: {
                            Text("Limpar")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartVM: CartViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Imagem
            AsyncImage(url: URL(string: item.image ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 80)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Informações
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "Produto")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(item.brand ?? "")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                
                Text("R$ \(formatPrice(Int(item.price)))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("MainGreen"))
            }
            
            Spacer()
            
            // Botão de remover
            Button {
                withAnimation {
                    cartVM.removeFromCart(item: item)
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
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
    
    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
}
