//
//  chatsviewmodel.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 10/02/2026.
//

import Foundation
import Combine

class ChatsViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    private let chatService = ChatService()
    private var chatStreamTask: Task<Void, Never>?
    
    func startListeningToChats(userID: String) {
        chatStreamTask?.cancel()
        
        chatStreamTask = Task {
            do {
                for try await chats in chatService.listenToUserChats(userID: userID) {
                    await MainActor.run {
                        self.chats = chats
                    }
                }
            } catch {
                print("Chat listener error: \(error)")
                // Handle error (show alert, retry, etc.)
            }
        }
    }
    
    func stopListening() {
        chatStreamTask?.cancel()
        chatStreamTask = nil
    }
}
