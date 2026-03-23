import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color("MainBlack")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundStyle(Color("MainGreen"))
                
                Text("Harmonica")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 20)
            }
        }
    }
}
