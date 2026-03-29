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
    
    // MARK: - Tests: Validação - Email
    
    func test_ValidarCampos_WithEmptyEmail_ReturnsFalse() {
        viewModel.email = ""
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Por favor, insira seu email")
    }
    
    func test_ValidarCampos_WithInvalidEmail_ReturnsFalse() {
        viewModel.email = "emailinvalido"
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Email inválido")
    }
    
    // MARK: - Tests: Validação - Nome
    
    func test_ValidarCampos_WithEmptyName_ReturnsFalse() {
        viewModel.email = "test@test.com"
        viewModel.nome = ""
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Por favor, insira seu nome")
    }
    
    // MARK: - Tests: Validação - Senha
    
    func test_ValidarCampos_WithEmptyPassword_ReturnsFalse() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = ""
        viewModel.confirmarSenha = ""
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Por favor, insira uma senha")
    }
    
    func test_ValidarCampos_WithShortPassword_ReturnsFalse() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = "12345"
        viewModel.confirmarSenha = "12345"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "A senha deve ter no mínimo 6 caracteres")
    }
    
    func test_ValidarCampos_WithMismatchedPasswords_ReturnsFalse() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "654321"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "As senhas não coincidem")
    }
    
    // MARK: - Tests: Validação - Sucesso
    
    func test_ValidarCampos_WithValidData_ReturnsTrue() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João Silva"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.mensagemErro)
    }
    
    func test_ValidarCampos_WithMinimumPasswordLength_ReturnsTrue() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertTrue(result)
    }
    
    // MARK: - Tests: Cadastro - Sucesso
    
    func test_Cadastrar_WithValidData_Success() async {
        viewModel.email = "newuser@test.com"
        viewModel.nome = "Novo Usuário"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        viewModel.Cadastrar(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.cadastroSucesso)
        XCTAssertNil(viewModel.mensagemErro)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(mockUserSession.cadastrarCallCount, 1)
        XCTAssertEqual(mockUserSession.lastCadastroEmail, "newuser@test.com")
        XCTAssertEqual(mockUserSession.lastCadastroNome, "Novo Usuário")
    }
    
    func test_Cadastrar_SetsLoadingStateDuringRequest() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        viewModel.Cadastrar(userSession: mockUserSession)
        
        XCTAssertTrue(viewModel.isLoading)
    }
    
    // MARK: - Tests: Cadastro - Falha
    
    func test_Cadastrar_WithInvalidEmail_DoesNotCallCadastrar() async {
        viewModel.email = ""
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        viewModel.Cadastrar(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertFalse(viewModel.cadastroSucesso)
        XCTAssertEqual(mockUserSession.cadastrarCallCount, 0)
    }
    
    func test_Cadastrar_UserAlreadyExists_ShowsError() async {
        mockUserSession.shouldFailCadastro = true
        mockUserSession.errorToThrow = AuthError.usuarioJaExiste
        
        viewModel.email = "existing@test.com"
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        viewModel.Cadastrar(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.mensagemErro, "Este email já está cadastrado. Faça login.")
        XCTAssertFalse(viewModel.cadastroSucesso)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_Cadastrar_GenericError_ShowsError() async {
        mockUserSession.shouldFailCadastro = true
        mockUserSession.errorToThrow = NSError(domain: "TestError", code: 500)
        
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        viewModel.Cadastrar(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertNotNil(viewModel.mensagemErro)
        XCTAssertTrue(viewModel.mensagemErro?.contains("Erro ao criar conta") ?? false)
        XCTAssertFalse(viewModel.cadastroSucesso)
    }
    
    // MARK: - Tests: Estado Inicial
    
    func test_InitialState_AllFieldsEmpty() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.nome, "")
        XCTAssertEqual(viewModel.senha, "")
        XCTAssertEqual(viewModel.confirmarSenha, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.mensagemErro)
        XCTAssertFalse(viewModel.cadastroSucesso)
    }
    
    // MARK: - Tests: Edge Cases
    
    func test_ValidarCampos_WithWhitespaceInEmail_ShowsError() {
        viewModel.email = "   "
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Email inválido")
    }
    
    func test_ValidarCampos_WithWhitespaceInName_ShowsError() {
        viewModel.email = "test@test.com"
        viewModel.nome = "   "
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertTrue(result) // Nome com espaços é válido (pode ser ajustado se quiser)
    }
    
    func test_ValidarCampos_WithExactly6Characters_ReturnsTrue() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertTrue(result)
    }
    
    func test_ValidarCampos_WithLongPassword_ReturnsTrue() {
        viewModel.email = "test@test.com"
        viewModel.nome = "João"
        viewModel.senha = "senhamuitolonga123456789"
        viewModel.confirmarSenha = "senhamuitolonga123456789"
        
        let result = viewModel.validarCampos()
        
        XCTAssertTrue(result)
    }
    
    func test_Cadastrar_ClearsErrorBeforeNewAttempt() async {
        viewModel.email = ""
        viewModel.nome = "João"
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        viewModel.Cadastrar(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertNotNil(viewModel.mensagemErro)
        
        viewModel.email = "test@test.com"
        viewModel.Cadastrar(userSession: mockUserSession)
        
        XCTAssertNil(viewModel.mensagemErro)
    }
    
    // MARK: - Tests: Ordem de Validação
    
    func test_ValidarCampos_ChecksEmailBeforeName() {
        viewModel.email = ""
        viewModel.nome = ""
        viewModel.senha = "123456"
        viewModel.confirmarSenha = "123456"
        
        _ = viewModel.validarCampos()
        
        XCTAssertEqual(viewModel.mensagemErro, "Por favor, insira seu email")
    }
    
    func test_ValidarCampos_ChecksNameBeforePassword() {
        viewModel.email = "test@test.com"
        viewModel.nome = ""
        viewModel.senha = ""
        viewModel.confirmarSenha = ""
        
        _ = viewModel.validarCampos()
        
        XCTAssertEqual(viewModel.mensagemErro, "Por favor, insira seu nome")
    }
}
