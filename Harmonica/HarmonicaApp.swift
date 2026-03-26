import SwiftUI

@main
struct HarmonicaApp: App {

    @StateObject private var userSession = UserSession()
    @StateObject private var cartVM = CartViewModel()

    var body: some Scene {
        WindowGroup {

            Group {
                if userSession.isLoading {
                    SplashView()

                } else if userSession.isAuthenticated {
                    MainView()
                        .environmentObject(userSession)
                        .environmentObject(cartVM)

                } else {
                    LoginView()
                        .environmentObject(userSession)
                        .environmentObject(cartVM)
                }
            }
            .onAppear {
                cartVM.observeUserSession(userSession)
            }
        }
    }
}
