import SwiftUI

@main
struct HarmonicaApp: App {
    @StateObject private var userSession = UserSession()
    
    init() {
        let session = UserSession()
        _userSession = StateObject(wrappedValue: session)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userSession.isLoading {
                    SplashView()
                } else if userSession.isAuthenticated {
                    MainView()
                        .environmentObject(userSession)
                } else {
                    LoginView()
                        .environmentObject(userSession)
                }
            }
        }
    }
}
