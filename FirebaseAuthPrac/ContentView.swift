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
                            ChatView()
                        } else {
                            AuthView()
                        }
        }
        .onAppear {
            

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
