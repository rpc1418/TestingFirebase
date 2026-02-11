//
//  Signup.swift
//  FirebaseAuthPrac
//
//  Created by rentamac on 06/02/2026.
//

import SwiftUI

struct AuthView: View {
    @State var num: String = ""
    @State var pass: String = ""
    @State var msg: String = ""
    let authSErvice: AuthService = AuthService()
    var body: some View {
        Spacer()
        Text("Login")
        TextField("Number", text: $num)
        SecureField("Password", text: $pass)
        Button("Login") {
            Task{
                msg = try await authSErvice.login(phone: num, password: pass)
            }
            
        }
        Spacer()
        Text("Signup")
        TextField("Number", text: $num)
        SecureField("Password", text: $pass)
        Button("Signup") {
            Task{
                msg = try await authSErvice.signup(phone: num, password: pass)
            }
        }
        Spacer()
        Text(msg)
        Spacer()
    }
}
