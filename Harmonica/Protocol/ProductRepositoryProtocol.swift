import Foundation

protocol ProductRepositoryProtocol {
    func getProducts() async throws -> [ProductModel]
    func postProduct(_ product: ProductModel) async throws -> ProductModel?
}
