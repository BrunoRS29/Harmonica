import XCTest
import CoreData
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
    
    private func createMockProduct(id: String = "1", name: String = "Test Product", price: Int = 100) -> ProductModel {
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
    
    func test_AddToFavorites_Success() {
        let product = createMockProduct(name: "Guitarra")
        
        viewModel.addToFavorites(product: product)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertEqual(viewModel.favoriteItems.first?.name, "Guitarra")
        XCTAssertTrue(viewModel.isFavorite(productId: "1"))
    }
    
    func test_AddToFavorites_DuplicateProduct_DoesNotAdd() {
        let product = createMockProduct()
        
        viewModel.addToFavorites(product: product)
        viewModel.addToFavorites(product: product)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
    }
    
    func test_AddToFavorites_WithoutUserEmail_DoesNotAdd() {
        viewModel.userEmail = nil
        
        viewModel.addToFavorites(product: createMockProduct())
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
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
        XCTAssertEqual(savedItem.price, 5000)
        XCTAssertEqual(savedItem.specs_color, "Sunburst")
        XCTAssertEqual(savedItem.specs_weight_kg, 3.5)
    }
    
    func test_RemoveFromFavorites_Success() {
        let product = createMockProduct()
        viewModel.addToFavorites(product: product)
        
        viewModel.removeFromFavorites(item: viewModel.favoriteItems.first!)
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
        XCTAssertFalse(viewModel.isFavorite(productId: "1"))
    }
    
    func test_RemoveFromFavorites_SpecificItem_RemovesOnlyThatItem() {
        viewModel.addToFavorites(product: createMockProduct(id: "1"))
        viewModel.addToFavorites(product: createMockProduct(id: "2"))
        
        let itemToRemove = viewModel.favoriteItems.first(where: { $0.id == "1" })!
        viewModel.removeFromFavorites(item: itemToRemove)
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertEqual(viewModel.favoriteItems.first?.id, "2")
    }
    
    func test_ToggleFavorite_AddsWhenNotFavorite() {
        viewModel.toggleFavorite(product: createMockProduct())
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertTrue(viewModel.isFavorite(productId: "1"))
    }
    
    func test_ToggleFavorite_RemovesWhenAlreadyFavorite() {
        let product = createMockProduct()
        viewModel.addToFavorites(product: product)
        
        viewModel.toggleFavorite(product: product)
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
    }
    
    func test_ToggleFavorite_MultipleTimes_TogglesCorrectly() {
        let product = createMockProduct()
        
        viewModel.toggleFavorite(product: product)
        XCTAssertTrue(viewModel.isFavorite(productId: "1"))
        
        viewModel.toggleFavorite(product: product)
        XCTAssertFalse(viewModel.isFavorite(productId: "1"))
        
        viewModel.toggleFavorite(product: product)
        XCTAssertTrue(viewModel.isFavorite(productId: "1"))
    }
    
    func test_FetchFavorites_IsolatesUserData() {
        viewModel.userEmail = "user1@test.com"
        viewModel.addToFavorites(product: createMockProduct(id: "1"))
        
        viewModel.userEmail = "user2@test.com"
        viewModel.addToFavorites(product: createMockProduct(id: "2"))
        
        viewModel.userEmail = "user1@test.com"
        viewModel.fetchFavorites()
        
        XCTAssertEqual(viewModel.favoriteItems.count, 1)
        XCTAssertEqual(viewModel.favoriteItems.first?.id, "1")
    }
    
    func test_FetchFavorites_WithoutUserEmail_DoesNotLoad() {
        viewModel.userEmail = nil
        
        viewModel.fetchFavorites()
        
        XCTAssertTrue(viewModel.favoriteItems.isEmpty)
    }
}
