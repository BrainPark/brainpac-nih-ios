//
//  BrainPACView.swift
//  
//
//  Created by Faisha Surjatin on 7/6/2023.
//

import SwiftUI
import Foundation

public enum BrainPACGame : String {
    case bart = "BART"
    case sst = "SST"
}

@available(iOS 13.0, *)
public struct BrainPACView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var game: BrainPACGame
    var onSessionComplete: ((String, String) -> Void)
    
    public init(game: BrainPACGame, onSessionComplete: @escaping (String, String) -> Void) {
        self.game = game
        self.onSessionComplete = onSessionComplete
    }
    
    public var body: some View {
        VStack{}
        .onAppear{
            // Set host window so app can return to key window after Unity unloads
            let window : UIWindow? = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }
            Unity.shared.setHostMainWindow(window)
            Unity.shared.onSessionCompleteCallback = self.onSessionComplete
            
            // Pop this view from stack when Unity window unloads
            Unity.shared.onUnload(callback: {
                presentationMode.wrappedValue.dismiss()
            })
            
            Unity.shared.show()
            Unity.shared.sendMessage(
                "GameManager",
                methodName: "LoadGame",
                message: game.rawValue
            )
        }
    }
}
