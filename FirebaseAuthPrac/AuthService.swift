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

    func signup(phone: String, password: String) async throws {
        let email = phoneToEmail(phone)

      
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                    continuation.resume(throwing: error)
                } else if let authResult = authResult {
                    continuation.resume(returning: authResult)
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
    }


  
    func login(phone: String, password: String) async throws {
        let email = phoneToEmail(phone)
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            auth.signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                    continuation.resume(throwing: error)
                } else if let authResult = authResult {
                    continuation.resume(returning: authResult)
                }
            }
        }
    }
    
    
    
    
    


    func logout() throws {
        try auth.signOut()
    }


    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }
    
    
    
    
    func fetchUser(byPhone phone: String, completion: @escaping (AppUser?) -> Void) {
        let query = db.child("users").queryOrdered(byChild: "phone").queryEqual(toValue: phone)
        
        query.observeSingleEvent(of: .value) { snapshot, _ in
            guard snapshot.exists() else {
                completion(nil)
                return
            }

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let dict = child.value as? [String: Any],
                   let phone = dict["phone"] as? String,
                   let email = dict["email"] as? String,
                   let name = dict["name"] as? String,
                   let profileImageURL = dict["profileImageURL"] as? String,
                   let createdAt = dict["createdAt"] as? TimeInterval {

                    let user = AppUser(
                        uid: child.key,
                        phone: phone,
                        email: email,
                        name: name,
                        profileImageURL: profileImageURL,
                        createdAt: createdAt
                    )
                    completion(user)
                    return
                }
            }

            completion(nil)
        }
    }

}

