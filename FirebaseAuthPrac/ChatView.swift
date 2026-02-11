//
//  ChatView.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 07/02/2026.
//

import SwiftUI

import FirebaseAuth
import FirebaseDatabase

struct ChatView: View {
    @State var phNo = ""
    @EnvironmentObject var authSession: AuthSession
    @State var fetchedUser = ""
    @State private var curUser: AppUser?
    @State private var fetchUser: AppUser?
    @State var chats: [Chat] = []
    let chatService = ChatService()
    let authService = AuthService()

    var body: some View {
        VStack {
            if let curUser {
                Text("Hello, \(curUser )")
            } else {
                Text("loading...")
            }
            

            Button("logout") {
                do {
                    try authService.logout()
                } catch {
                    print(error)
                }
            }

            TextField("Phone Number", text: $phNo)
                .textFieldStyle(.roundedBorder)

            Button("fetch user with number") {
                Task {
                    let user = await authService.fetchUser(byPhone: phNo)

                    if let user {
                        fetchedUser =
                        """
                        User found:
                        Name: \(user.name)
                        UID: \(user.uid)
                        Phone: \(user.phone)
                        """
                        fetchUser = user
                    } else {
                        fetchedUser = "User not found"
                    }
                }
            }

            Text(fetchedUser)
            
            Button("Create Chat") {
                Task{
                    if let curUser, let fetchUser {
                        do{
                            try await chatService.createChat(
                                participants: [curUser.uid, fetchUser.uid],
                                isGroup: false
                            )
                        }catch {
                            print("Failed to fetch chats:", error)
                        }
                        
                    }
                }
                
            }
            Spacer()
            Button("Fetch all chats"){
                Task {
                    do {
                        chats = try await chatService.fetchChats(for: "6X6bM3e4fcVI8pgGzXdr1eedHyy2")
                        print(chats)
                    } catch {
                        print("Failed to fetch chats:", error)
                    }
                }
            }
            
            Button("send message to a chat "){
                Task {
                    do {
                        try await chatService.sendMessage(
                            chatID: "ZqUC7cWSVLvjkdVQOx5n",
                            senderID: "6X6bM3e4fcVI8pgGzXdr1eedHyy2",
                            text: "update more test live"
                        )
                    } catch {
                        print("Failed to fetch chats:", error)
                    }
                }
            }
            NavigationLink("Open Chat", destination:
                ChatDetailView(chatID: "ZqUC7cWSVLvjkdVQOx5n", currentUserID: "6X6bM3e4fcVI8pgGzXdr1eedHyy2")
            )
            
            NavigationLink("Show all te chats", destination: ChatsView())
            
            Button("fetch single chat"){
                Task {
                            do {
                                let result = try await chatService.fetchChat(by: "ZqUC7cWSVLvjkdVQOx5n")
                                await MainActor.run {
                                    print(result)
                                }
                            } catch {
                                await MainActor.run {
                                    print(error)
                                }
                            }
                        }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                curUser = await authService.loadCurrentUser(authSession: authSession)
                print(curUser!)
            }
        }
    }
}
