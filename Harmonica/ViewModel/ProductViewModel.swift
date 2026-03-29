// ViewModels/ProductViewModel.swift

import Combine
import CoreData

class ProductViewModel: ObservableObject {
    let container: NSPersistentContainer
    private let repository: ProductRepositoryProtocol
    
    @Published var products: [ProductModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
        
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { descr, error in
            if let error = error {
                print("❌ Erro no CoreData: \(error.localizedDescription)")
            } else {
                print("✅ CoreData pronto!")
            }
        }
    }
    
    //MARK: - Fetch da API
    
    func loadProducts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedProducts = try await repository.getProducts()
                
                await MainActor.run {
                    self.products = fetchedProducts
                    self.isLoading = false
                    print("📦 \(fetchedProducts.count) produtos carregados da API")
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erro ao buscar produtos: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ \(error)")
                }
            }
        }
    }
    
    //MARK: - Post Product
    
    func createProduct(_ product: ProductModel) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let newProduct = try await repository.postProduct(product)
                
                await MainActor.run {
                    if let newProduct = newProduct {
                        self.products.append(newProduct)
                        print("✅ Produto criado: \(newProduct.name)")
                    }
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erro ao criar produto: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ \(error)")
                }
            }
        }
    }
}
