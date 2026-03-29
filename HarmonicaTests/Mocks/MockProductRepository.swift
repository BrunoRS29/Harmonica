import Foundation
@testable import Harmonica

class MockProductRepository: ProductRepositoryProtocol {
    
    var mockProducts: [ProductModel] = []
    var mockCreatedProduct: ProductModel?
    var shouldFailGetProducts = false
    var shouldFailPostProduct = false
    var errorToThrow: Error = NetworkError.invalidResponse
    
    var getProductsCallCount = 0
    var postProductCallCount = 0
    var lastPostedProduct: ProductModel?
    
    func getProducts() async throws -> [ProductModel] {
        getProductsCallCount += 1
        
        if shouldFailGetProducts {
            throw errorToThrow
        }
        
        return mockProducts
    }
    
    func postProduct(_ product: ProductModel) async throws -> ProductModel? {
        postProductCallCount += 1
        lastPostedProduct = product
        
        if shouldFailPostProduct {
            throw errorToThrow
        }
        
        return mockCreatedProduct
    }
}
