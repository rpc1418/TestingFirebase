//
//  chatmodel.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 07/02/2026.
//

import FirebaseFirestore

struct Chat: Identifiable {
    let id: String
    let participants: [String]
    let isGroup: Bool
    let name: String?
    let lastMessage: String
    let lastUpdated: Timestamp
}
