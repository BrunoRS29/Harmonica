import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(code: Int)
}

class ProductRepository: ProductRepositoryProtocol {
    
    private let baseURL = "https://69c5423b8a5b6e2dec2c126d.mockapi.io/api/instruments/instruments/"
    
    func getProducts() async throws -> [ProductModel] {
        
        guard let url = URL(string: baseURL) else {
            print("❌ URL INVÁLIDA")
            throw NetworkError.invalidURL
        }
        
        let (data, responseMetadata) = try await URLSession.shared.data(from: url)
        
        print("🔄 Dados recebidos: \(data)")
        
        guard let response = responseMetadata as? HTTPURLResponse else {
            print("❌ Invalid response")
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(response.statusCode) else {
            print("❌ Erro de servidor")
            throw NetworkError.httpError(code: response.statusCode)
        }
        
        print(String(data: data, encoding: .utf8) ?? "")
        let decoder = JSONDecoder()
        let products = try decoder.decode([ProductModel].self, from: data)
        return products
    }
    
    func postProduct(_ product: ProductModel) async throws -> ProductModel? {
            
        guard let url = URL(string: baseURL) else {
            print("❌ URL INVÁLIDA")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(product)
            request.httpBody = jsonData
            
            print("📤 Enviando produto: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            let (data, responseMetadata) = try await URLSession.shared.data(for: request)
            
            guard let response = responseMetadata as? HTTPURLResponse else {
                print("❌ Invalid response")
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(response.statusCode) else {
                print("❌ Erro de servidor: \(response.statusCode)")
                throw NetworkError.httpError(code: response.statusCode)
            }
            
            print("✅ Produto criado com sucesso")
            
            let decoder = JSONDecoder()
            let newProduct = try decoder.decode(ProductModel.self, from: data)
            
            return newProduct
            
        } catch {
            print("❌ Erro no POST: \(error.localizedDescription)")
            throw error
        }
    }
}
