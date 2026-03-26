import Combine
import CoreData

class ProductViewModel: ObservableObject {
    let container: NSPersistentContainer
    let remote = ProductRepository()
    
    @Published var products: [ProductModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
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
                let fetchedProducts = try await remote.getProducts()
                
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
}
