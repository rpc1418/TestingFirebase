
//
//  message.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 07/02/2026.
//
import Foundation
import FirebaseFirestore
struct Message: Identifiable , Equatable{
    let id: String
    let senderID: String
    let text: String
    let timestamp: Timestamp
    let readBy: [String]
}
