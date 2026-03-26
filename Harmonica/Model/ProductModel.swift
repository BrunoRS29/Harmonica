import Foundation

struct ProductResponse: Codable {
    let products: [ProductModel]
}

struct ProductModel: Codable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let category: String
    let price: Int
    let image: String
    let specs: SpecsModel
}

struct SpecsModel: Codable {
    let color: String
    let primary_material: String
    let weight_kg: Double
    let dimensions_cm: String
}
