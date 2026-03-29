import SwiftUI

@main
struct HarmonicaApp: App {

    @StateObject private var userSession = UserSession()
    @StateObject private var cartVM = CartViewModel()
    @StateObject private var favoriteVM = FavoriteViewModel()

    var body: some Scene {
        WindowGroup {

            Group {
                if userSession.isLoading {
                    SplashView()

                } else if userSession.isAuthenticated {
                    MainView()
                        .environmentObject(userSession)
                        .environmentObject(cartVM)
                        .environmentObject(favoriteVM)

                } else {
                    LoginView()
                        .environmentObject(userSession)
                        .environmentObject(cartVM)
                        .environmentObject(favoriteVM)
                }
            }
            .onAppear {
                cartVM.observeUserSession(userSession)
                favoriteVM.observeUserSession(userSession)
            }
        }
    }
}
