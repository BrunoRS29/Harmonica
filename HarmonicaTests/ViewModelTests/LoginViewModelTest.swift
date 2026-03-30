import XCTest
@testable import Harmonica

@MainActor
final class LoginViewModelTest: XCTestCase {
    
    var viewModel: LoginViewModel!
    var mockUserSession: MockUserSession!
    
    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
        mockUserSession = MockUserSession()
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserSession = nil
        super.tearDown()
    }
    
    func test_ValidarCampos_WithEmptyEmail_ReturnsFalse() {
        viewModel.email = ""
        viewModel.senha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Por favor, insira seu email")
    }
    
    func test_ValidarCampos_WithEmptyPassword_ReturnsFalse() {
        viewModel.email = "test@test.com"
        viewModel.senha = ""
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Por favor, insira sua senha")
    }
    
    func test_ValidarCampos_WithInvalidEmail_ReturnsFalse() {
        viewModel.email = "emailinvalido"
        viewModel.senha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.mensagemErro, "Email inválido")
    }
    
    func test_ValidarCampos_WithValidCredentials_ReturnsTrue() {
        viewModel.email = "test@test.com"
        viewModel.senha = "123456"
        
        let result = viewModel.validarCampos()
        
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.mensagemErro)
    }
    
    func test_FazerLogin_WithValidCredentials_Success() async {
        viewModel.email = "test@test.com"
        viewModel.senha = "123456"
        
        viewModel.fazerLogin(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(viewModel.loginSucesso)
        XCTAssertNil(viewModel.mensagemErro)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_FazerLogin_WithInvalidEmail_DoesNotCallLogin() async {
        viewModel.email = ""
        viewModel.senha = "123456"
        
        viewModel.fazerLogin(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertFalse(viewModel.loginSucesso)
        XCTAssertEqual(mockUserSession.loginCallCount, 0)
    }
    
    func test_FazerLogin_UserNotFound_ShowsError() async {
        mockUserSession.shouldFailLogin = true
        mockUserSession.errorToThrow = AuthError.usuarioNaoEncontrado
        
        viewModel.email = "notfound@test.com"
        viewModel.senha = "123456"
        
        viewModel.fazerLogin(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.mensagemErro, "Usuário não encontrado. Faça o cadastro primeiro.")
        XCTAssertFalse(viewModel.loginSucesso)
    }
    
    func test_FazerLogin_WrongPassword_ShowsError() async {
        mockUserSession.shouldFailLogin = true
        mockUserSession.errorToThrow = AuthError.senhaIncorreta
        
        viewModel.email = "test@test.com"
        viewModel.senha = "wrongpassword"
        
        viewModel.fazerLogin(userSession: mockUserSession)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.mensagemErro, "Senha incorreta. Tente novamente.")
        XCTAssertFalse(viewModel.loginSucesso)
    }
    
    func test_FazerLogin_SetsLoadingStateDuringRequest() {
        viewModel.email = "test@test.com"
        viewModel.senha = "123456"
        
        viewModel.fazerLogin(userSession: mockUserSession)
        
        XCTAssertTrue(viewModel.isLoading)
    }
    
    func test_InitialState_AllFieldsEmpty() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.senha, "")
        XCTAssertFalse(viewModel.lembreSenha)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.mensagemErro)
        XCTAssertFalse(viewModel.loginSucesso)
        XCTAssertFalse(viewModel.navegarParaCadastro)
    }
}
