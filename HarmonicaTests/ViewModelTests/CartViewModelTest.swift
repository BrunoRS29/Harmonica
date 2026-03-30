import XCTest
import CoreData
@testable import Harmonica

@MainActor
final class CartViewModelTest: XCTestCase {
    
    var viewModel: CartViewModel!
    var testContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        testContainer = CoreDataTestHelper.createInMemoryContainer()
        
        viewModel = CartViewModel(container: testContainer)
        viewModel.userEmail = "test@test.com"
    }
    
    override func tearDown() {
        viewModel = nil
        testContainer = nil
        super.tearDown()
    }
    
    func test_AddToCart_Success_IncreasesCount() {
        let product = createMockProduct(id: "1", name: "Guitarra", price: 1000)
        
        viewModel.addToCart(product: product)
        
        XCTAssertEqual(viewModel.cartItems.count, 1)
        XCTAssertEqual(viewModel.cartItems.first?.name, "Guitarra")
        XCTAssertEqual(viewModel.totalPrice, 1000)
    }
    
    func test_AddToCart_DuplicateProduct_DoesNotAdd() {
        let product = createMockProduct(id: "1", name: "Violão", price: 500)
        viewModel.addToCart(product: product)
        
        viewModel.addToCart(product: product)
        
        XCTAssertEqual(viewModel.cartItems.count, 1)
    }
    
    func test_RemoveFromCart_Success_DecreasesCount() {
        let product = createMockProduct(id: "1", name: "Piano", price: 5000)
        viewModel.addToCart(product: product)
        let itemToRemove = viewModel.cartItems.first!
        
        viewModel.removeFromCart(item: itemToRemove)
        
        XCTAssertTrue(viewModel.cartItems.isEmpty)
        XCTAssertEqual(viewModel.totalPrice, 0)
    }
    
    func test_ClearCart_RemovesAllItems() {
        viewModel.addToCart(product: createMockProduct(id: "1", name: "Item1", price: 100))
        viewModel.addToCart(product: createMockProduct(id: "2", name: "Item2", price: 200))
        
        viewModel.clearCart()
        
        XCTAssertTrue(viewModel.cartItems.isEmpty)
        XCTAssertEqual(viewModel.totalPrice, 0)
    }
    
    func test_IsInCart_ReturnsTrueForExistingProduct() {
        let product = createMockProduct(id: "123", name: "Teste", price: 100)
        viewModel.addToCart(product: product)
        
        XCTAssertTrue(viewModel.isInCart(productId: "123"))
    }
    
    func test_IsInCart_ReturnsFalseForNonExistingProduct() {
        XCTAssertFalse(viewModel.isInCart(productId: "999"))
    }
    
    func test_TotalPrice_CalculatesCorrectly() {
        viewModel.addToCart(product: createMockProduct(id: "1", name: "Item1", price: 100))
        viewModel.addToCart(product: createMockProduct(id: "2", name: "Item2", price: 200))
        viewModel.addToCart(product: createMockProduct(id: "3", name: "Item3", price: 300))
        
        XCTAssertEqual(viewModel.totalItems, 3)
        XCTAssertEqual(viewModel.totalPrice, 600)
    }
    
    func test_FormattedTotalPrice_FormatsCorrectly() {
        viewModel.addToCart(product: createMockProduct(id: "1", name: "Item", price: 1500))
        
        let formatted = viewModel.formattedTotalPrice
        
        XCTAssertTrue(formatted.contains("R$"))
        XCTAssertTrue(formatted.contains("1") && formatted.contains("500"))
    }
    
    func test_SetUser_ChangesUserEmail() {
        viewModel.setUser(email: "newuser@test.com")
        
        XCTAssertEqual(viewModel.userEmail, "newuser@test.com")
    }
    
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
                dimensions_cm: "100x50x20"
            )
        )
    }
}

class CoreDataTestHelper {
    
    static func createInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Model")
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Erro ao criar container in-memory: \(error)")
            }
        }
        
        return container
    }
}
