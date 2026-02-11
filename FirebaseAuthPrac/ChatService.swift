//
//  ChatService.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 07/02/2026.
//

import FirebaseFirestore
final class ChatService {
    
    let db = Firestore.firestore()
    
    
    func createChat(
            participants: [String],
            isGroup: Bool,
            name: String? = nil
        ) async throws -> String {
            var chatData: [String: Any] = [
                "participants": participants,
                "isGroup": isGroup,
                "lastMessage": "",
                "lastUpdated": Timestamp(date: Date()),
                "lastRead": Dictionary(
                    uniqueKeysWithValues: participants.map { ($0, Timestamp(date: Date())) }
                )
            ]
            
            if isGroup, let name = name {
                chatData["name"] = name
            }
            
            let chatRef = db.collection("chats").document()
            try await chatRef.setData(chatData)
            
            print("Chat created successfully: \(chatRef.documentID)")
            return chatRef.documentID
        }
        
        /// Sends a message and updates chat metadata
        func sendMessage(
            chatID: String,
            senderID: String,
            text: String
        ) async throws {
            let messageData: [String: Any] = [
                "senderID": senderID,
                "text": text,
                "timestamp": Timestamp(date: Date()),
                "readBy": [senderID]
            ]
            
            let chatRef = db.collection("chats").document(chatID)
            let messageRef = chatRef.collection("messages").document()
            
            try await withThrowingTaskGroup(of: Void.self) { group in
                // Add message
                group.addTask {
                    try await messageRef.setData(messageData)
                }
                
                // Update chat metadata
                group.addTask {
                    try await chatRef.updateData([
                        "lastMessage": text,
                        "lastUpdated": Timestamp(date: Date()),
                        "lastRead.\(senderID)": Timestamp(date: Date())
                    ])
                }
                
                try await group.waitForAll()
            }
        }



    func fetchChats(for uid: String) async throws -> [Chat] {
        let db = Firestore.firestore()

        let snapshot = try await db.collection("chats")
            .whereField("participants", arrayContains: uid)
            .order(by: "lastUpdated", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()

            return Chat(
                id: doc.documentID,
                participants: data["participants"] as? [String] ?? [],
                isGroup: data["isGroup"] as? Bool ?? false,
                name: data["name"] as? String,
                lastMessage: data["lastMessage"] as? String ?? "",
                lastUpdated: data["lastUpdated"] as? Timestamp ?? Timestamp()
            )
        }
    }
    func listenToUserChats(userID: String) -> AsyncThrowingStream<[Chat], Error> {
            AsyncThrowingStream { continuation in
                let query = db.collection("chats")
                    .whereField("participants", arrayContains: userID)
                    .order(by: "lastUpdated", descending: true)
                
                let listener = query.addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }
                    
                    let chats = snapshot?.documents.compactMap { doc -> Chat? in
                        let data = doc.data()
                        return Chat(
                            id: doc.documentID,
                            participants: data["participants"] as? [String] ?? [],
                            isGroup: data["isGroup"] as? Bool ?? false,
                            name: data["name"] as? String,
                            lastMessage: data["lastMessage"] as? String ?? "",
                            lastUpdated: data["lastUpdated"] as? Timestamp ?? Timestamp()
                        )
                    } ?? []
                    
                    continuation.yield(chats)
                }
                
                continuation.onTermination = { _ in
                    listener.remove()
                }
            }
        }

    func listenToMessages(chatID: String) -> AsyncThrowingStream<[Message], Error> {
        let db = Firestore.firestore()

        return AsyncThrowingStream { continuation in
            let listener = db.collection("chats")
                .document(chatID)
                .collection("messages")
                .order(by: "timestamp", descending: false)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.finish(throwing: error)
                        return
                    }

                    let messages = snapshot?.documents.compactMap { doc -> Message in
                        let data = doc.data()
                        return Message(
                            id: doc.documentID,
                            senderID: data["senderID"] as? String ?? "",
                            text: data["text"] as? String ?? "",
                            timestamp: data["timestamp"] as? Timestamp ?? Timestamp(),
                            readBy: data["readBy"] as? [String] ?? []
                        )
                    } ?? []

                    continuation.yield(messages)
                }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    
    func fetchChat(by chatID: String) async throws -> Chat? {
            let doc = try await db.collection("chats")
                .document(chatID)
                .getDocument()
            
            guard let data = doc.data() else {
                return nil   // chat not found / deleted
            }
            
            return Chat(
                id: doc.documentID,
                participants: data["participants"] as? [String] ?? [],
                isGroup: data["isGroup"] as? Bool ?? false,
                name: data["name"] as? String,
                lastMessage: data["lastMessage"] as? String ?? "",
                lastUpdated: data["lastUpdated"] as? Timestamp ?? Timestamp()
            )
        }
}
