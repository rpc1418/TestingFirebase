//
//  AppDelegate.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 06/02/2026.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("App Started")
    return true
  }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App moved to background")
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("App entering foreground")
    }

}
//
//@main
//struct YourApp: App {
//  // register app delegate for Firebase setup
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//  var body: some Scene {
//    WindowGroup {
//      NavigationView {
//        ContentView()
//      }
//    }
//  }
//}
