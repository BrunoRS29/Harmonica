import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("MainBlack")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 60)
                    
                    logoField
                    signInField
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Voltar")
                    }
                    .foregroundStyle(Color("MainGreen"))
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
    
    var signInField: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Criar Conta")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Preencha os dados abaixo")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Nome", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                
                TextField("Seu nome completo", text: $viewModel.nome)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }
            
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
                
                SecureField("", text: $viewModel.senha, prompt: Text("Mínimo 6 caracteres").foregroundStyle(.white.opacity(0.5)))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Confirmar Senha", systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                
                SecureField("", text: $viewModel.confirmarSenha, prompt: Text("Digite a senha novamente").foregroundStyle(.white.opacity(0.5)))
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
            }
            
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
                    viewModel.Cadastrar(userSession: userSession)
                }
            }) {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.title3)
                        Text("Criar Conta")
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
                Text("Já tem uma conta?")
                    .foregroundStyle(.white.opacity(0.7))
                Button("Faça login") {
                    dismiss()
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
        .onChange(of: viewModel.cadastroSucesso) {
            if viewModel.cadastroSucesso {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(UserSession())
    }
}
