//
//  AuthSession.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 06/02/2026.
//

import FirebaseAuth
import SwiftUI
import Combine

@MainActor
final class AuthSession: ObservableObject {

    @Published var user: User?
    @Published var isLoading = true

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            self.isLoading = false
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
