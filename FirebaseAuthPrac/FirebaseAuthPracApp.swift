//
//  FirebaseAuthPracApp.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 06/02/2026.
//

import SwiftUI

@main
struct FirebaseAuthPracApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authSession = AuthSession()
    @Environment(\.scenePhase) var scenePhase
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView().environmentObject(authSession)
            }
            
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("App is active")
            case .background:
                print("App is in background")
            case .inactive:
                print("App is inactive")

            @unknown default:
                break
            }
        }
    }
}
