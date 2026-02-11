//
//  ç.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 10/02/2026.
//

import SwiftUI
import FirebaseFirestore


struct ChatsView: View {
    @StateObject private var viewModel = ChatsViewModel()
    let userID = "6X6bM3e4fcVI8pgGzXdr1eedHyy2"

  // From AuthViewModel
    
    var body: some View {
        List(viewModel.chats) { chat in
            NavigationLink(chat.id) {
                ChatDetailView(chatID: chat.id, currentUserID:  "6X6bM3e4fcVI8pgGzXdr1eedHyy2")
            }
            Text(chat.lastMessage)
        }
        .onAppear {
            viewModel.startListeningToChats(userID: userID)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}



