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
    
    
}
