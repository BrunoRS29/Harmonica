import Combine
import CoreData

class FavoriteViewModel: ObservableObject {

    let container: NSPersistentContainer
    var userEmail: String?

    private var cancellables = Set<AnyCancellable>()

    @Published var favoriteItems: [FavoriteItem] = []

    init(container: NSPersistentContainer? = nil) {
        if let container = container {
            self.container = container
        } else {
            self.container = NSPersistentContainer(name: "Model")
            self.container.loadPersistentStores { _, error in
                if let error = error {
                    print("❌ CoreData Favorites:", error.localizedDescription)
                } else {
                    print("✅ CoreData Favorites pronto!")
                }
            }
        }
    }

    // MARK: - Observar usuário

    func observeUserSession(_ session: UserSession) {

        if let email = session.usuarioAtual?.email {
            self.userEmail = email
            fetchFavorites()
        }

        session.$usuarioAtual
            .sink { [weak self] user in
                guard let self = self else { return }

                if let email = user?.email {
                    self.userEmail = email
                    self.fetchFavorites()
                } else {
                    self.userEmail = nil
                    self.favoriteItems = []
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    func fetchFavorites() {

        guard let email = userEmail else { return }

        let request = NSFetchRequest<FavoriteItem>(entityName: "FavoriteItem")
        request.predicate = NSPredicate(format: "userEmail == %@", email)

        do {
            favoriteItems = try container.viewContext.fetch(request)
            print("❤️ Favoritos:", favoriteItems.count)
        } catch {
            print("❌ Erro ao buscar favoritos:", error.localizedDescription)
        }
    }

    // MARK: - Check

    func isFavorite(productId: String) -> Bool {
        favoriteItems.contains(where: { $0.id == productId })
    }

    // MARK: - Add

    func addToFavorites(product: ProductModel) {

        guard let email = userEmail else { return }

        if isFavorite(productId: product.id) {
            return
        }

        let item = FavoriteItem(context: container.viewContext)

        item.userEmail = email
        item.id = product.id
        item.name = product.name
        item.brand = product.brand
        item.category = product.category
        item.image = product.image
        item.price = Int64(product.price)
        item.specs_color = product.specs.color
        item.specs_primary_material = product.specs.primary_material
        item.specs_weight_kg = product.specs.weight_kg
        item.specs_dimensions_cm = product.specs.dimensions_cm

        print("❤️ Produto favoritado:", product.name, "| Usuário:", email)
        
        save()
    }

    // MARK: - Remove

    func removeFromFavorites(item: FavoriteItem) {
        container.viewContext.delete(item)
        save()
    }

    // MARK: - Toggle

    func toggleFavorite(product: ProductModel) {

        if let item = favoriteItems.first(where: { $0.id == product.id }) {
            removeFromFavorites(item: item)
        } else {
            addToFavorites(product: product)
        }
    }

    // MARK: - Save

    private func save() {
        do {
            try container.viewContext.save()
            fetchFavorites()
        } catch {
            print("❌ Erro ao salvar favorito:", error.localizedDescription)
        }
    }
}
