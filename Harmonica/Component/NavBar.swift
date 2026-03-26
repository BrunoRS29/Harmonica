import SwiftUI

struct NavBar: View {
    @Binding var selectedTab: Int
    
    let icons = ["guitars.fill", "plus.capsule", "person.fill"]
    let names = ["Loja", "Procura", "Perfil"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<icons.count, id: \.self) { index in
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 6) {
                        
                        Image(systemName: icons[index])
                            .font(.system(size: 22, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundStyle(selectedTab == index ? Color("MainGreen") : .white.opacity(0.5))
                            .frame(height: 28)
                        
                        // Indicador embaixo
                        if selectedTab == index {
                            Circle()
                                .fill(Color("MainGreen"))
                                .frame(width: 4, height: 4)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .fill(.clear)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 5)
        .background(
            Color.black
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color("MainGreen").opacity(0.1), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 1),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    ZStack {
        Color("MainBlack").ignoresSafeArea()
        
        VStack {
            Spacer()
            NavBar(selectedTab: .constant(0))
        }
    }
}
