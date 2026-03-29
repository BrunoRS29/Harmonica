import XCTest
@testable import Harmonica

@MainActor
final class ProductViewModelTest: XCTestCase {
    
    var viewModel: ProductViewModel!
    var mockRepository: MockProductRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockProductRepository()
        viewModel = ProductViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Tests: getProducts (Success)
    
    func test_LoadProducts_Success_ReturnsProducts() async {
        let mockProduct1 = createMockProduct(id: "1", name: "Guitarra")
        let mockProduct2 = createMockProduct(id: "2", name: "Violão")
        mockRepository.mockProducts = [mockProduct1, mockProduct2]
        
        viewModel.loadProducts()
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        XCTAssertEqual(viewModel.products.count, 2)
        XCTAssertEqual(viewModel.products[0].name, "Guitarra")
        XCTAssertEqual(viewModel.products[1].name, "Violão")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockRepository.getProductsCallCount, 1)
    }
    
    func test_LoadProducts_Success_EmptyList() async {
        mockRepository.mockProducts = []
        
        viewModel.loadProducts()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Tests: getProducts (Failure)
    
    func test_LoadProducts_Failure_NetworkError() async {
        mockRepository.shouldFailGetProducts = true
        mockRepository.errorToThrow = NetworkError.invalidResponse
        
        viewModel.loadProducts()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Erro ao buscar produtos") ?? false)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_LoadProducts_Failure_HTTPError() async {
        mockRepository.shouldFailGetProducts = true
        mockRepository.errorToThrow = NetworkError.httpError(code: 500)
        
        viewModel.loadProducts()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Tests: postProduct (Success)
    
    func test_CreateProduct_Success() async {
        let productToCreate = createMockProduct(id: "3", name: "Bateria")
        mockRepository.mockCreatedProduct = productToCreate
        
        viewModel.createProduct(productToCreate)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first?.name, "Bateria")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockRepository.postProductCallCount, 1)
        XCTAssertEqual(mockRepository.lastPostedProduct?.name, "Bateria")
    }
    
    // MARK: - Tests: postProduct (Failure)
    
    func test_CreateProduct_Failure() async {
        let productToCreate = createMockProduct(id: "4", name: "Piano")
        mockRepository.shouldFailPostProduct = true
        mockRepository.errorToThrow = NetworkError.httpError(code: 400)
        
        viewModel.createProduct(productToCreate)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.products.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Erro ao criar produto") ?? false)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Tests: Loading State
    
    func test_LoadProducts_SetsLoadingStateCorrectly() {
        viewModel.loadProducts()
        
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Helper Methods
    
    private func createMockProduct(id: String, name: String) -> ProductModel {
        ProductModel(
            id: id,
            name: name,
            brand: "Test Brand",
            category: "Test Category",
            price: 1000,
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
