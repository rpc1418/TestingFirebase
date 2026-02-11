//
//  chatDetails.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 07/02/2026.
//

import SwiftUI
import FirebaseAuth

struct ChatDetailView: View {
    let chatID: String
    let currentUserID: String
    
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    
    let chatService = ChatService()
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(messages) { message in
                            HStack {
                                if message.senderID == currentUserID {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { _ in
                    if let last = messages.last {
                        withAnimation {
                            scrollView.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    Task{
                        let text = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        
                        do{
                            try await chatService.sendMessage(
                                chatID: chatID,
                                senderID: currentUserID,
                                text: text
                            )
                        }catch {
                            print("Failed to fetch chats:", error)
                        }
                        
                        
                        
                        newMessage = ""
                    }
                    
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            Task {
                do {
                    for try await msgs in chatService.listenToMessages(chatID: chatID) {
                        self.messages = msgs
                    }
                } catch {
                    print("Failed to listen to messages:", error)
                }
            }
        }
    }
}
