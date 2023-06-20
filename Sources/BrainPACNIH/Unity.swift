//
//  Unity.swift
//  
//
//  Created by Faisha Surjatin on 7/6/2023.
//  Taken and adapted from https://medium.com/mop-developers/communicate-with-a-unity-game-embedded-in-a-swiftui-ios-app-1cefb38ff439
//

import Foundation
import UnityFramework

public class Unity: UIResponder, UIApplicationDelegate {
    
    // The structure for Unity messages
    private struct UnityMessage {
        let objectName: String?
        let methodName: String?
        let messageBody: String?
    }

    private var cachedMessages = [UnityMessage]() // Array of cached messages
    public static let shared = Unity()

    private let dataBundleId: String = "com.unity3d.framework"
    private let frameworkPath: String = "/Frameworks/UnityFramework.framework"

    private var ufw : UnityFramework?
    var hostMainWindow : UIWindow?
    
    var unloadCallback : (() -> Void)?
    public var onSessionCompleteCallback: ((String, String) -> Void)?

    private var isInitialized: Bool {
        ufw?.appController() != nil
    }

    public func show() {
        if isInitialized {
            showWindow()
        } else {
            initWindow()
        }
    }
    
    public func dismiss() {
        unloadWindow()
    }
    
    public func onUnload(callback: @escaping () -> Void) {
        unloadCallback = callback
    }

    public func setHostMainWindow(_ hostMainWindow: UIWindow?) {
        self.hostMainWindow = hostMainWindow
    }
    
    // Main method for sending a message to Unity
    public func sendMessage(
        _ objectName: String,
        methodName: String,
        message: String
    ) {
        let msg: UnityMessage = UnityMessage(
            objectName: objectName,
            methodName: methodName,
            messageBody: message
        )

        // Send the message right away if Unity is initialized, else cache it
        if isInitialized {
            ufw?.sendMessageToGO(
                withName: msg.objectName,
                functionName: msg.methodName,
                message: msg.messageBody
            )
        } else {
            cachedMessages.append(msg)
        }
    }

    private func initWindow() {
        if isInitialized {
            showWindow()
            return
        }

        guard let ufw = loadUnityFramework() else {
            print("ERROR: Was not able to load Unity")
            return unloadWindow()
        }

        self.ufw = ufw
        ufw.setDataBundleId(dataBundleId)
        ufw.register(self)
        NSClassFromString("FrameworkLibAPI")?.registerAPIforNativeCalls(self)
        ufw.runEmbedded(
            withArgc: CommandLine.argc,
            argv: CommandLine.unsafeArgv,
            appLaunchOpts: nil
        )

        sendCachedMessages() // Added this line
    }

    private func showWindow() {
        if isInitialized {
            ufw?.showUnityWindow()
            sendCachedMessages()
        }
    }

    private func unloadWindow() {
        if isInitialized {
            cachedMessages.removeAll()
            ufw?.unloadApplication()
        }
    }

    private func loadUnityFramework() -> UnityFramework? {
        let bundlePath: String = Bundle.main.bundlePath + frameworkPath

        let bundle = Bundle(path: bundlePath)
        if bundle?.isLoaded == false {
            bundle?.load()
        }

        let ufw = bundle?.principalClass?.getInstance()
        if ufw?.appController() == nil {
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header

            ufw?.setExecuteHeader(machineHeader)
        }
        return ufw
    }

    // Send all previously cached messages, if any
    private func sendCachedMessages() {
        if cachedMessages.count >= 0 && isInitialized {
            for msg in cachedMessages {
                ufw?.sendMessageToGO(
                    withName: msg.objectName,
                    functionName: msg.methodName,
                    message: msg.messageBody
                )
            }

            cachedMessages.removeAll()
        }
    }
}

extension Unity: UnityFrameworkListener {

    public func unityDidUnload(_ notification: Notification!) {
        ufw?.unregisterFrameworkListener(self)
        ufw = nil
        hostMainWindow?.makeKeyAndVisible()
        if let callback = unloadCallback {
            callback()
        }
    }
}

extension Unity: NativeCallsProtocol {
    public func onSessionComplete(_ resultsPath: String!, schema schemaUrl: String!) {
        if let callback = onSessionCompleteCallback {
            callback(resultsPath, schemaUrl)
        }
        unloadWindow()
    }
}
