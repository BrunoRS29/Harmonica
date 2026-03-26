import Combine
import CoreData

class CartViewModel: ObservableObject {
    
    let container: NSPersistentContainer
    var userEmail: String?
    
    private var cancellables = Set<AnyCancellable>()
    
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
    }
    
    //MARK: - Fetch
    
    func fetchCartItems() {
        guard let email = userEmail else { return }
        
        let request = NSFetchRequest<CartItem>(entityName: "CartItem")
        request.predicate = NSPredicate(format: "userEmail == %@", email)
        
        do {
            self.cartItems = try container.viewContext.fetch(request)
            print("🛒 Itens no carrinho de \(email):", cartItems.count)
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

        print("🛒 Tentando adicionar:", product.name)

        guard let email = userEmail else {
            print("❌ userEmail está NIL")
            return
        }

        print("✅ usuário do carrinho:", email)

        if isInCart(productId: product.id) {
            print("⚠️ Produto já está no carrinho")
            return
        }

        let newItem = CartItem(context: container.viewContext)
        newItem.userEmail = email
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
    
    func setUser(email: String) {
        self.userEmail = email
        fetchCartItems()
    }
    
    func observeUserSession(_ session: UserSession) {

        // pega o usuário atual imediatamente
        if let email = session.usuarioAtual?.email {
            print("👤 usuário atual detectado:", email)
            self.userEmail = email
            fetchCartItems()
        }

        // observa mudanças futuras
        session.$usuarioAtual
            .sink { [weak self] user in
                guard let self = self else { return }

                if let email = user?.email {
                    print("🔄 usuário mudou:", email)
                    self.userEmail = email
                    self.fetchCartItems()
                } else {
                    print("🚪 logout detectado")
                    self.userEmail = nil
                    self.cartItems = []
                }
            }
            .store(in: &cancellables)
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
