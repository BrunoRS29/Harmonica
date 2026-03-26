import SwiftUI

struct MainView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Conteúdo baseado na tab selecionada
            switch selectedTab {
            case 0:
                HomeView()
            case 1:
                AnnounceView()
            case 2:
                ProfileView()
            default:
                HomeView()
            }
            
            // NavBar fixo embaixo
            VStack {
                Spacer()
                NavBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainView()
        .environmentObject(UserSession())
}
