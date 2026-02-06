//
//  ContentView.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 06/02/2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase


struct ContentView: View {
    @EnvironmentObject var authSession: AuthSession
    let authService = AuthService()
    var body: some View {
        VStack {
            if authSession.isLoading {
                            Text("Loading...")
                        } else if authSession.user != nil {
                            Text("Hello, \(authSession.user!.email!)")
                            Button("logout"){
                                Task{
                                    try authService.logout()
                                }
                            }
                        } else {
                            AuthView()
                        }
        }
        .onAppear {
            let authService = AuthService()
            authService.fetchUser(byPhone: "1") { user in
                if let user = user {
                    print("User found:", user.name, user.email)
                    print(user)
                } else {
                    print("User not found")
                }
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
