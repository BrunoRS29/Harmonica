import XCTest
@testable import Harmonica

@MainActor
final class SignInViewModelTest: XCTestCase {
    
    var viewModel: SignInViewModel!
    var mockUserSession: MockUserSession!
    
    override func setUp() {
        super.setUp()
        viewModel = SignInViewModel()
        mockUserSession = MockUserSession()
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserSession = nil
        super.tearDown()
    }
    
    private func setupValidViewModel() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João Silva"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
    }
    
    private func assertValidationFails(with expectedError: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(viewModel.validarCampos(), file: file, line: line)
        XCTAssertEqual(viewModel.mensagemErro, expectedError, file: file, line: line)
    }
    
    func test_ValidarCampos_WithInvalidInputs_ShowsCorrectErrors() {
        // Email vazio
        viewModel.email = ""
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        assertValidationFails(with: "Por favor, insira seu email")
        
        // Email inválido
        viewModel.email = "emailinvalido"
        assertValidationFails(with: "Email inválido")
        
        // Nome vazio
        viewModel.email = "test@test.com"
        viewModel.nome = ""
        assertValidationFails(with: "Por favor, insira seu nome")
        
        // Senha vazia
        viewModel.nome = "João"
        viewModel.senha = ""
        viewModel.confirmarSenha = ""
        assertValidationFails(with: "Por favor, insira uma senha")
        
        // Senha curta
        viewModel.senha = "12345"
        viewModel.confirmarSenha = "12345"
        assertValidationFails(with: "A senha deve ter no mínimo 6 caracteres")
        
        // Senhas não coincidem
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "654321"
        assertValidationFails(with: "As senhas não coincidem")
    }
    
    func test_ValidarCampos_WithValidData_ReturnsTrue() {
        setupValidViewModel()
        
        XCTAssertTrue(viewModel.validarCampos())
        XCTAssertNil(viewModel.mensagemErro)
    }
    
    func test_Cadastrar_WithValidData_Success() async {
        setupValidViewModel()
        
        viewModel.Cadastrar(userSession: mockUserSession)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.cadastroSucesso)
        XCTAssertNil(viewModel.mensagemErro)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(mockUserSession.cadastrarCallCount, 1)
        XCTAssertEqual(mockUserSession.lastCadastroEmail, "test@test.com")
        XCTAssertEqual(mockUserSession.lastCadastroNome, "João Silva")
    }
    
    func test_Cadastrar_WithInvalidData_DoesNotCallCadastrar() async {
        viewModel.email = ""
        
        viewModel.Cadastrar(userSession: mockUserSession)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertFalse(viewModel.cadastroSucesso)
        XCTAssertEqual(mockUserSession.cadastrarCallCount, 0)
    }
    
    func test_Cadastrar_WithErrors_ShowsCorrectMessages() async {
        setupValidViewModel()
        
        // Usuário já existe
        mockUserSession.shouldFailCadastro = true
        mockUserSession.errorToThrow = AuthError.usuarioJaExiste
        viewModel.Cadastrar(userSession: mockUserSession)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.mensagemErro, "Este email já está cadastrado. Faça login.")
        XCTAssertFalse(viewModel.cadastroSucesso)
        
        mockUserSession.errorToThrow = NSError(domain: "TestError", code: 500)
        viewModel.Cadastrar(userSession: mockUserSession)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.mensagemErro?.contains("Erro ao criar conta") ?? false)
        XCTAssertFalse(viewModel.cadastroSucesso)
    }
    
    func test_InitialState_AllFieldsEmpty() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.nome, "")
        XCTAssertEqual(viewModel.senha, "")
        XCTAssertEqual(viewModel.confirmarSenha, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.mensagemErro)
        XCTAssertFalse(viewModel.cadastroSucesso)
    }
    
    func test_Cadastrar_SetsLoadingState() {
        setupValidViewModel()
        
        viewModel.Cadastrar(userSession: mockUserSession)
        
        XCTAssertTrue(viewModel.isLoading)
    }
}
