import SwiftUI

struct MainView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
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
