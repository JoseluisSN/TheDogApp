//
//  SignUpView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 12/02/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @AppStorage("uid") var userID: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 5) {
                Text("Create an Account!")
                    .foregroundColor(.black)
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("We need your email and password to create an account")
                    .font(.system(size: 19))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.black)
            }.padding(.horizontal, 20).padding(.top, 10)
            
            VStack(spacing: 6) {
                CustomTextField(icon: "pawprint", placeholder: "Email", text: $email)
                    .padding(.bottom, 4)
                
                CustomSecureField(icon: "lock", placeholder: "Password", text: $password)
            }.padding(.horizontal, 20)
                .padding(.top, 13)
            
            Button {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    if let authResult = authResult {
                        print(authResult.user.uid)
                        userID = authResult.user.uid
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
            } label: {
                Text("Create New Account")
                    .foregroundColor(.black)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical)
            }.padding(.top, 10)
            
            Spacer()
            
        } .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        
        return passwordRegex.evaluate(with: password)
    }
}

#Preview {
    SignUpView()
}
