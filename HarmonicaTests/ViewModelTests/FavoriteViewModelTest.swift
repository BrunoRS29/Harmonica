import XCTest
import CoreData
import Combine
@testable import Harmonica

@MainActor
final class FavoriteViewModelTest: XCTestCase {
    
    var viewModel: FavoriteViewModel!
    var testContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        testContainer = CoreDataTestHelper.createInMemoryContainer()
        
        viewModel = FavoriteViewModel(container: testContainer)
        viewModel.userEmail = "test@test.com"
    }
    
    override func tearDown() {
        viewModel = nil
        testContainer = nil
        super.tearDown()
    }
    
    // MARK: - Tests: Add to Favorites
    
    func test_AddToFavorites_Success_IncreasesCount() {
        let product = createMockProduct(id: "1", name: "Guitarra", price: 1000)
        
        viewModel.addToFavorites(product: product)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertEqual(viewModel.favoriteItems.first?.name, "Guitarra")
        XCTAssertEqual(viewModel.favoriteItems.first?.id, "1")
    }
    
    func test_AddToFavorites_DuplicateProduct_DoesNotAdd() {
        let product = createMockProduct(id: "1", name: "Violão", price: 500)
        viewModel.addToFavorites(product: product)
        
        viewModel.addToFavorites(product: product)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1, "Não deve adicionar produto duplicado")
    }
    
    func test_AddToFavorites_WithoutUserEmail_DoesNotAdd() {
        viewModel.userEmail = nil
        let product = createMockProduct(id: "1", name: "Bateria", price: 2000)
        
        viewModel.addToFavorites(product: product)
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
    }
    
    func test_AddToFavorites_MultipleProducts_AddsAll() {
        let product1 = createMockProduct(id: "1", name: "Item1", price: 100)
        let product2 = createMockProduct(id: "2", name: "Item2", price: 200)
        let product3 = createMockProduct(id: "3", name: "Item3", price: 300)
        
        viewModel.addToFavorites(product: product1)
        viewModel.addToFavorites(product: product2)
        viewModel.addToFavorites(product: product3)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 3)
    }
    
    func test_AddToFavorites_SavesAllProductData() {
        let product = ProductModel(
            id: "123",
            name: "Guitarra Fender",
            brand: "Fender",
            category: "Cordas",
            price: 5000,
            image: "https://example.com/guitar.jpg",
            specs: SpecsModel(
                color: "Sunburst",
                primary_material: "Madeira",
                weight_kg: 3.5,
                dimensions_cm: "100x40x10"
            )
        )
        
        viewModel.addToFavorites(product: product)
        
        let savedItem = viewModel.favoriteItems.first!
        XCTAssertEqual(savedItem.id, "123")
        XCTAssertEqual(savedItem.name, "Guitarra Fender")
        XCTAssertEqual(savedItem.brand, "Fender")
        XCTAssertEqual(savedItem.category, "Cordas")
        XCTAssertEqual(savedItem.price, 5000)
        XCTAssertEqual(savedItem.image, "https://example.com/guitar.jpg")
        XCTAssertEqual(savedItem.specs_color, "Sunburst")
        XCTAssertEqual(savedItem.specs_primary_material, "Madeira")
        XCTAssertEqual(savedItem.specs_weight_kg, 3.5)
        XCTAssertEqual(savedItem.specs_dimensions_cm, "100x40x10")
    }
    
    // MARK: - Tests: Remove from Favorites
    
    func test_RemoveFromFavorites_Success_DecreasesCount() {
        let product = createMockProduct(id: "1", name: "Piano", price: 5000)
        viewModel.addToFavorites(product: product)
        let itemToRemove = viewModel.favoriteItems.first!
        
        viewModel.removeFromFavorites(item: itemToRemove)
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
    }
    
    func test_RemoveFromFavorites_SpecificItem_RemovesOnlyThatItem() {
        let product1 = createMockProduct(id: "1", name: "Item1", price: 100)
        let product2 = createMockProduct(id: "2", name: "Item2", price: 200)
        viewModel.addToFavorites(product: product1)
        viewModel.addToFavorites(product: product2)
        
        let itemToRemove = viewModel.favoriteItems.first(where: { $0.id == "1" })!
        
        viewModel.removeFromFavorites(item: itemToRemove)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertEqual(viewModel.favoriteItems.first?.id, "2")
    }
    
    // MARK: - Tests: IsFavorite
    
    func test_IsFavorite_ReturnsTrueForExistingProduct() {
        let product = createMockProduct(id: "123", name: "Teste", price: 100)
        viewModel.addToFavorites(product: product)
        
        let result = viewModel.isFavorite(productId: "123")
        
        XCTAssertTrue(result)
    }
    
    func test_IsFavorite_ReturnsFalseForNonExistingProduct() {
        let result = viewModel.isFavorite(productId: "999")
        
        XCTAssertFalse(result)
    }
    
    func test_IsFavorite_ReturnsFalseAfterRemoval() {
        let product = createMockProduct(id: "1", name: "Item", price: 100)
        viewModel.addToFavorites(product: product)
        let item = viewModel.favoriteItems.first!
        
        viewModel.removeFromFavorites(item: item)
        
        XCTAssertFalse(viewModel.isFavorite(productId: "1"))
    }
    
    // MARK: - Tests: Toggle Favorite
    
    func test_ToggleFavorite_AddsWhenNotFavorite() {
        let product = createMockProduct(id: "1", name: "Guitarra", price: 1000)
        
        viewModel.toggleFavorite(product: product)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertTrue(viewModel.isFavorite(productId: "1"))
    }
    
    func test_ToggleFavorite_RemovesWhenAlreadyFavorite() {
        let product = createMockProduct(id: "1", name: "Violão", price: 500)
        viewModel.addToFavorites(product: product)
        
        viewModel.toggleFavorite(product: product)
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
        XCTAssertFalse(viewModel.isFavorite(productId: "1"))
    }
    
    func test_ToggleFavorite_MultipleTimes_TogglesCorrectly() {
        let product = createMockProduct(id: "1", name: "Bateria", price: 2000)
        
        viewModel.toggleFavorite(product: product)
        XCTAssertTrue(viewModel.isFavorite(productId: "1"))
        
        viewModel.toggleFavorite(product: product)
        XCTAssertFalse(viewModel.isFavorite(productId: "1"))
        
        viewModel.toggleFavorite(product: product)
        XCTAssertTrue(viewModel.isFavorite(productId: "1"))
    }
    
    // MARK: - Tests: Fetch Favorites
    
    func test_FetchFavorites_LoadsItemsForCurrentUser() {
        let product = createMockProduct(id: "1", name: "Item", price: 100)
        viewModel.addToFavorites(product: product)
        viewModel.favoriteItems = []
        
        viewModel.fetchFavorites()
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
    }
    
    func test_FetchFavorites_WithoutUserEmail_DoesNotLoad() {
        viewModel.userEmail = nil
        
        viewModel.fetchFavorites()
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
    }
    
    func test_FetchFavorites_IsolatesUserData() {
        viewModel.userEmail = "user1@test.com"
        viewModel.addToFavorites(product: createMockProduct(id: "1", name: "Item1", price: 100))
        
        viewModel.userEmail = "user2@test.com"
        viewModel.addToFavorites(product: createMockProduct(id: "2", name: "Item2", price: 200))
        
        viewModel.userEmail = "user1@test.com"
        viewModel.fetchFavorites()
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertEqual(viewModel.favoriteItems.first?.id, "1")
    }
    
    // MARK: - Helper Methods
    
    private func createMockProduct(id: String, name: String, price: Int) -> ProductModel {
        ProductModel(
            id: id,
            name: name,
            brand: "Test Brand",
            category: "Test Category",
            price: price,
            image: "https://example.com/image.jpg",
            specs: SpecsModel(
                color: "Black",
                primary_material: "Wood",
                weight_kg: 2.5,
                dimensions_cm: "100x50x10"
            )
        )
    }
}
