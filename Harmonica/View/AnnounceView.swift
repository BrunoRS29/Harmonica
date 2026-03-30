import SwiftUI

struct AnnounceView: View {
    @State private var name = ""
    @State private var brand = ""
    @State private var category = ""
    @State private var price = ""
    @State private var image = ""
    @State private var color = ""
    @State private var material = ""
    @State private var weight = ""
    @State private var dimensions = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    // Categorias fixas
    let categories = ["Cordas", "Sopro", "Percussão", "Teclas", "Eletrônicos"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MainBlack").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Anunciar Produto")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("Preencha os dados do seu instrumento")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            
                            SectionHeader(title: "Informações Básicas")
                            
                            CustomTextField(
                                icon: "music.note",
                                placeholder: "Nome do Produto",
                                text: $name
                            )
                            
                            CustomTextField(
                                icon: "tag",
                                placeholder: "Marca",
                                text: $brand
                            )
                            
                            CategoryPicker(
                                selectedCategory: $category,
                                categories: categories
                            )
                            
                            CustomTextField(
                                icon: "dollarsign.circle",
                                placeholder: "Preço (apenas números)",
                                text: $price,
                                keyboardType: .numberPad
                            )
                            
                            CustomTextField(
                                icon: "photo",
                                placeholder: "URL da Imagem",
                                text: $image
                            )
                            
                            SectionHeader(title: "Especificações")
                            
                            CustomTextField(
                                icon: "paintpalette",
                                placeholder: "Cor",
                                text: $color
                            )
                            
                            CustomTextField(
                                icon: "hammer",
                                placeholder: "Material Principal",
                                text: $material
                            )
                            
                            CustomTextField(
                                icon: "scalemass",
                                placeholder: "Peso (kg)",
                                text: $weight,
                                keyboardType: .decimalPad
                            )
                            
                            CustomTextField(
                                icon: "ruler",
                                placeholder: "Dimensões (ex: 100x40x15)",
                                text: $dimensions
                            )
                        }
                        .padding(.horizontal)
                        
                        // Botão de Anunciar
                        Button {
                            criarProduto()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    Text("Anunciar Produto")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("MainGreen"))
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || !isFormValid())
                        .opacity(isFormValid() ? 1.0 : 0.5)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert(isLoading ? "Criando produto..." : "Resultado", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("✅") {
                        limparFormulario()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Validação
    func isFormValid() -> Bool {
        return !name.isEmpty &&
               !brand.isEmpty &&
               !category.isEmpty &&
               !price.isEmpty &&
               !image.isEmpty &&
               !color.isEmpty &&
               !material.isEmpty &&
               !weight.isEmpty &&
               !dimensions.isEmpty
    }
    
    // MARK: - Criar Produto
    func criarProduto() {
        guard let priceInt = Int(price),
              let weightDouble = Double(weight.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "❌ Preço ou peso inválido"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let novoProduto = ProductModel(
            id: UUID().uuidString,
            name: name,
            brand: brand,
            category: category,
            price: priceInt,
            image: image,
            specs: SpecsModel(
                color: color,
                primary_material: material,
                weight_kg: weightDouble,
                dimensions_cm: dimensions
            )
        )
        
        Task {
            do {
                let repo = ProductRepository()
                let produtoCriado = try await repo.postProduct(novoProduto)
                
                await MainActor.run {
                    if let produto = produtoCriado {
                        alertMessage = """
                        ✅ Produto anunciado com sucesso!
                        
                        Nome: \(produto.name)
                        Preço: R$ \(produto.price)
                        """
                    } else {
                        alertMessage = "❌ Erro ao criar produto"
                    }
                    isLoading = false
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "❌ Erro: \(error.localizedDescription)"
                    isLoading = false
                    showAlert = true
                }
            }
        }
    }
    
    // MARK: - Limpar Formulário
    func limparFormulario() {
        name = ""
        brand = ""
        category = ""
        price = ""
        image = ""
        color = ""
        material = ""
        weight = ""
        dimensions = ""
    }
}

// MARK: - Category Picker
struct CategoryPicker: View {
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        Menu {
            ForEach(categories, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    HStack {
                        Text(category)
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "folder")
                    .foregroundStyle(Color("MainGreen"))
                    .frame(width: 24)
                
                Text(selectedCategory.isEmpty ? "Selecione a Categoria" : selectedCategory)
                    .foregroundStyle(selectedCategory.isEmpty ? .white.opacity(0.5) : .white)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundStyle(.white.opacity(0.5))
                    .font(.caption)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color("MainGreen"))
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .foregroundStyle(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}

#Preview {
    AnnounceView()
}
