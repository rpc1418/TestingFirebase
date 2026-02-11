//
//  AuthService.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 06/02/2026.
//

import FirebaseAuth
import FirebaseDatabase


final class AuthService {

    private let auth = Auth.auth()
    private let db = Database.database().reference()
    

    private func phoneToEmail(_ phone: String) -> String {
        return "\(phone)@app.com"
    }
    
    func phoneFromEmail(_ email: String) -> String {
        return email.replacingOccurrences(of: "@app.com", with: "")
    }


    func signup(phone: String, password: String) async throws -> String{
        let email = phoneToEmail(phone)
        var msg = ""
      
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                    msg = error.localizedDescription
                    continuation.resume(throwing: error)
                } else if let authResult = authResult {
                    continuation.resume(returning: authResult)
                    msg = "User created successfully"
                }
            }
        }

        let uid = result.user.uid
        let userData: [String: Any] = [
                "phone": phone,
                "email": email,
                "name": "dummy user",
                "profileImageURL": "dummy_url",
                "createdAt": ServerValue.timestamp()
            ]

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                db.child("users").child(uid).setValue(userData) { error, _ in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
            
            print("User created and saved in DB with uid: \(uid)")
        
        return msg
    }


  
    func login(phone: String, password: String) async throws -> String   {
        let email = phoneToEmail(phone)
        var msg = ""
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            auth.signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    msg = error.localizedDescription
                   
                } else if let authResult = authResult {
                    continuation.resume(returning: authResult)
                    msg = "login success"
                }
            }
        }
        return msg
    }
    
    
    
    
    


    func logout() throws {
        try auth.signOut()
    }


    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }
    
    
    
    
    
    func fetchUser(byPhone phone: String) async -> AppUser? {
        await withCheckedContinuation { continuation in
            let query = db.child("users")
                .queryOrdered(byChild: "phone")
                .queryEqual(toValue: phone)

            query.observeSingleEvent(of: .value) { snapshot, _ in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let dict = child.value as? [String: Any],
                       let phone = dict["phone"] as? String,
                       let email = dict["email"] as? String,
                       let name = dict["name"] as? String,
                       let profileImageURL = dict["profileImageURL"] as? String,
                       let createdAt = dict["createdAt"] as? TimeInterval {

                        continuation.resume(returning: AppUser(
                            uid: child.key,
                            phone: phone,
                            email: email,
                            name: name,
                            profileImageURL: profileImageURL,
                            createdAt: createdAt
                        ))
                        return
                    }
                }
                continuation.resume(returning: nil)
            }
        }
    }

    
    
    

    func loadCurrentUser(authSession: AuthSession) async -> AppUser? {
        guard let email = authSession.user?.email else { return nil }
        let phone = email.replacingOccurrences(of: "@app.com", with: "")
        return await fetchUser(byPhone: phone)
    }


}

