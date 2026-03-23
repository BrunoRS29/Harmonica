import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var userSession: UserSession
    @State private var mostrarSenha = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)
                
                logoField
                loginField
                
                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 30)
            .background(Color("MainBlack"))
            .navigationDestination(isPresented: $viewModel.navegarParaCadastro) {
                SignInView()
            }
            .onAppear {
                if let ultimoEmail = KeychainHelper.getLastEmail() {
                    viewModel.carregarCredenciais(email: ultimoEmail)
                }
            }
        }
    }
    
    var logoField: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 70, weight: .heavy))
                .foregroundStyle(Color("MainGreen"))
            
            Text("Harmonica")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
    
    var loginField: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Bem-vindo!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Entre para continuar")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Email", systemImage: "envelope.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                
                TextField("email@example.com", text: $viewModel.email)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Senha", systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                
                HStack {
                    if mostrarSenha {
                        TextField("••••••••", text: $viewModel.senha)
                            .foregroundStyle(.white)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("••••••••", text: $viewModel.senha)
                            .foregroundStyle(.white)
                            .autocorrectionDisabled()
                    }
                    
                    Button {
                        mostrarSenha.toggle()
                    } label: {
                        Image(systemName: mostrarSenha ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            
            HStack {
                Toggle(isOn: $viewModel.lembreSenha) {
                    Text("Lembrar senha")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .tint(Color("MainGreen"))
            }
            .padding(.vertical, 4)
            
            if let erro = viewModel.mensagemErro {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(erro)
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
                .transition(.scale.combined(with: .opacity))
            }
            
            Button(action: {
                withAnimation {
                    viewModel.fazerLogin(userSession: userSession)
                }
            }) {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                        Text("Entrar")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color("MainGreen"))
                .foregroundStyle(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 5)
            }
            .disabled(viewModel.isLoading)
            .padding(.top, 8)
            
            HStack(spacing: 4) {
                Text("Não tem uma conta?")
                    .foregroundStyle(.white.opacity(0.7))
                Button("Cadastre-se") {
                    viewModel.navegarParaCadastro = true
                }
                .foregroundStyle(Color("MainGreen"))
            }
            .font(.subheadline)
            .padding(.top, 8)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(UserSession())
}
