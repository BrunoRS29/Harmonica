import Combine
import CoreData

class CartViewModel: ObservableObject {
    let container: NSPersistentContainer
    
    @Published var cartItems: [CartItem] = []
    
    init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Erro no CoreData: \(error.localizedDescription)")
            } else {
                print("✅ CoreData (Cart) pronto!")
            }
        }
        fetchCartItems()
    }
    
    //MARK: - Fetch
    
    func fetchCartItems() {
        let request = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        do {
            self.cartItems = try container.viewContext.fetch(request)
            print("🛒 Itens no carrinho:", cartItems.count)
        } catch {
            print("❌ Erro ao buscar carrinho:", error.localizedDescription)
        }
    }
    
    //MARK: - Check if in cart
    
    func isInCart(productId: String) -> Bool {
        return cartItems.contains(where: { $0.id == productId })
    }
    
    //MARK: - Add
    
    func addToCart(product: ProductModel) {
        // Verifica se já existe
        if isInCart(productId: product.id) {
            print("⚠️ Produto já está no carrinho: \(product.name)")
            return
        }
        
        let newItem = CartItem(context: container.viewContext)
        newItem.id = product.id
        newItem.name = product.name
        newItem.brand = product.brand
        newItem.category = product.category
        newItem.image = product.image
        newItem.price = Int64(product.price)
        newItem.specs_color = product.specs.color
        newItem.specs_primary_material = product.specs.primary_material
        newItem.specs_weight_kg = product.specs.weight_kg
        newItem.specs_dimensions_cm = product.specs.dimensions_cm
        
        print("✅ Adicionado ao carrinho: \(product.name)")
        save()
    }
    
    //MARK: - Remove
    
    func removeFromCart(item: CartItem) {
        container.viewContext.delete(item)
        save()
        print("🗑️ Removido do carrinho: \(item.name ?? "")")
    }
    
    func clearCart() {
        cartItems.forEach { container.viewContext.delete($0) }
        save()
        print("🗑️ Carrinho limpo")
    }
    
    //MARK: - Save
    
    private func save() {
        do {
            try container.viewContext.save()
            fetchCartItems()
        } catch {
            print("❌ Erro ao salvar carrinho:", error.localizedDescription)
        }
    }
    
    //MARK: - Computed properties
    
    var totalItems: Int {
        return cartItems.count
    }
    
    var totalPrice: Int {
        return cartItems.reduce(0) { $0 + Int($1.price) }
    }
    
    var formattedTotalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "R$ " + (formatter.string(from: NSNumber(value: totalPrice)) ?? "\(totalPrice)")
    }
}
