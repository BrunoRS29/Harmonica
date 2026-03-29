import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var vm = ProductViewModel()
    @EnvironmentObject var cartVM: CartViewModel
    
    @State private var showCart: Bool = false
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "Todos"
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var categories: [String] {
        var cats = ["Todos"]
        let uniqueCategories = Set(vm.products.map { $0.category })
        cats.append(contentsOf: uniqueCategories.sorted())
        return cats
    }

    var filteredProducts: [ProductModel] {
        vm.products.filter { product in
            
            let matchesSearch = searchText.isEmpty ||
                product.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == "Todos" ||
                product.category == selectedCategory
            
            return matchesSearch && matchesCategory
        }
    }
    
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
                                .accessibilityIdentifier("welcomeText")
                            
                            Spacer()
                            
                            Button {
                                showCart.toggle()
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "cart")
                                        .font(.system(size: 25))
                                        .bold()
                                        .foregroundStyle(Color("MainGreen"))
                                    
                                    if !cartVM.cartItems.isEmpty {
                                        Text("\(cartVM.cartItems.count)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                            .frame(minWidth: 16, minHeight: 16)
                                            .padding(2)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 8, y: -8)
                                            .accessibilityIdentifier("cartBadge")
                                    }
                                }
                            }
                            .accessibilityIdentifier("cartButton")
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.gray)
                            
                            TextField("Buscar produto...", text: $searchText)
                                .foregroundStyle(.white)
                                .autocorrectionDisabled()
                                .accessibilityIdentifier("searchField")
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.gray)
                                }
                                .accessibilityIdentifier("clearSearchButton")
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .accessibilityIdentifier("searchBar")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategory = category
                                        }
                                    } label: {
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category ? Color("MainGreen") : Color.white.opacity(0.1))
                                            .foregroundStyle(selectedCategory == category ? .black : .white)
                                            .cornerRadius(20)
                                    }
                                    .accessibilityIdentifier("category_\(category)")
                                }
                            }
                            .padding(.horizontal)
                        }
                        .accessibilityIdentifier("categoryFilter")
                        
                        if vm.isLoading {
                            VStack(spacing: 20) {
                                ProgressView()
                                    .tint(Color("MainGreen"))
                                    .accessibilityIdentifier("loadingIndicator")
                                Text("Carregando produtos...")
                                    .foregroundStyle(.white.opacity(0.7))
                                    .accessibilityIdentifier("loadingText")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            
                        } else if let errorMessage = vm.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundStyle(.red)
                                    .accessibilityIdentifier("errorIcon")
                                
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                    .accessibilityIdentifier("errorMessage")
                                
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
                                .accessibilityIdentifier("retryButton")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            
                        } else if filteredProducts.isEmpty {
                            
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.gray)
                                    .accessibilityIdentifier("emptyStateIcon")
                                
                                Text("Nenhum produto encontrado")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .accessibilityIdentifier("emptyStateTitle")
                                
                                Text("Tente buscar por outro termo")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                    .accessibilityIdentifier("emptyStateSubtitle")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                            
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredProducts) { product in
                                    ProductItem(product: product)
                                        .accessibilityIdentifier("product_\(product.id)")
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                            .accessibilityIdentifier("productGrid")
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
        .environmentObject(CartViewModel())
}
