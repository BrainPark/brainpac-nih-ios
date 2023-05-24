// Created 5/23/23
// swift-tools-version:5.0

import SwiftUI
import BrainPAC

class AppDelegate : UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // syoung 05/24/2023 - This is where you could put a setup call, though this is currently doing nothing.
        // The UnityFramework is expecting this arg to be non-nil and have something in the launch options,
        // but the documentation doesn't tell what that is.
    
        return true;
    }
}

@main
struct TestAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
