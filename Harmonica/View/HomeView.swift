import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var vm = ProductViewModel()
    @EnvironmentObject var cartVM: CartViewModel
    
    @State private var showCart: Bool = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MainBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        HStack {
                            Text("Bem-vindo, \(userSession.usuarioAtual?.nome ?? "Visitante")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Button {
                                showCart.toggle()
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "cart")
                                        .font(.system(size: 35))
                                        .foregroundStyle(Color("MainGreen"))
                                    
                                    // Badge com quantidade
                                    if !cartVM.cartItems.isEmpty {
                                        Text("\(cartVM.cartItems.count)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(minWidth: 16, minHeight: 16)
                                            .padding(2)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 8, y: -8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(10)
                        
                        // Conteúdo
                        if vm.isLoading {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .tint(Color("MainGreen"))
                                Text("Carregando produtos...")
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            
                        } else if let errorMessage = vm.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundStyle(.red)
                                
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                
                                Button {
                                    vm.loadProducts()
                                } label: {
                                    Text("Tentar novamente")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color("MainGreen"))
                                        .cornerRadius(10)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(vm.products) { product in
                                    ProductItem(product: product)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .onAppear {
                vm.loadProducts()
            }
            .sheet(isPresented: $showCart) {
                CartView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserSession())
}
