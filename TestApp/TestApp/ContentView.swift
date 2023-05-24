// Created 5/23/23
// swift-tools-version:5.0

import SwiftUI
import BrainPAC

// TODO: syoung 05/24/2023 support simulator so that preview doesn't crash.

struct ContentView: View {
    let allGames = BrainPACUnity.sharedManager().allGames()
    @State var selected: BrainPACGame?
    
    var body: some View {
        ForEach(allGames, id: \.self) { game in
            Button(game.rawValue) {
                if selected == nil {
                    selected = game
                }
            }
            .padding()
        }
        .padding()
        .onChange(of: selected) { newValue in
            if let game = selected, let window = UIApplication.shared.currentKeyWindow {
                do {
                    try BrainPACUnity.sharedManager().show(game, from: window)
                } catch {
                    print("ERROR: failed to start game: \(error)")
                }
            }
        }
    }
}

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
