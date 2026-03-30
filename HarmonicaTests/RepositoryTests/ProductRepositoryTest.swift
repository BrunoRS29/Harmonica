import XCTest
@testable import Harmonica

final class ProductRepositoryTest: XCTestCase {
    
    var repository: ProductRepository!
    
    override func setUp() {
        super.setUp()
        repository = ProductRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    @MainActor
    func test_GetProducts_ReturnsValidData() async throws {
        let products = try await repository.getProducts()
        
        XCTAssertFalse(products.isEmpty)
        
        let product = try XCTUnwrap(products.first)
        XCTAssertFalse(product.id.isEmpty)
        XCTAssertFalse(product.name.isEmpty)
        XCTAssertGreaterThan(product.price, 0)
    }
    
    @MainActor
    func test_GetProducts_AllProductsHaveUniqueIDs() async throws {
        let products = try await repository.getProducts()
        
        let ids = products.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count)
    }
    
    func test_GetProducts_CompletesInReasonableTime() async throws {
        let start = Date()
        
        _ = try await repository.getProducts()
        
        let duration = Date().timeIntervalSince(start)
        XCTAssertLessThan(duration, 5.0)
    }
    
    @MainActor
    func test_PostProduct_CreatesNewProduct() async throws {
        let newProduct = ProductModel(
            id: "",
            name: "Test Guitar",
            brand: "Test Brand",
            category: "Cordas",
            price: 999,
            image: "https://example.com/test.jpg",
            specs: SpecsModel(
                color: "Black",
                primary_material: "Wood",
                weight_kg: 3.5,
                dimensions_cm: "100x40x10"
            )
        )
        
        let createdProduct = try await repository.postProduct(newProduct)
        
        XCTAssertNotNil(createdProduct)
        XCTAssertFalse(createdProduct?.id.isEmpty ?? true)
        XCTAssertEqual(createdProduct?.name, "Test Guitar")
        XCTAssertEqual(createdProduct?.price, 999)
    }
    
    @MainActor
    func test_PostAndGet_ProductAppearsInList() async throws {
        let uniqueName = "Test \(UUID().uuidString.prefix(8))"
        
        let newProduct = ProductModel(
            id: "",
            name: uniqueName,
            brand: "Test",
            category: "Test",
            price: 777,
            image: "https://example.com/test.jpg",
            specs: SpecsModel(
                color: "Blue",
                primary_material: "Plastic",
                weight_kg: 1.0,
                dimensions_cm: "50x20x10"
            )
        )
        
        _ = try await repository.postProduct(newProduct)
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let allProducts = try await repository.getProducts()
        let foundProduct = allProducts.first(where: { $0.name == uniqueName })
        
        XCTAssertNotNil(foundProduct)
    }
}
