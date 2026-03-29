import SwiftUI

struct ProductItem: View {
    let product: ProductModel
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: 8) {
                
                AsyncImage(url: URL(string: product.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFill()
                            .foregroundStyle(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 180, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    // Nome do produto
                    Text(product.name)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 40, alignment: .topLeading)
                    
                    // Marca
                    Text(product.brand)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    // Preço
                    Text("R$ \(formatPrice(product.price))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color("MainGreen"))
                    
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Formatar preço
    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}
