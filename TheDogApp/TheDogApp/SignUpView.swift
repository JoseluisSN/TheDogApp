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
    @State private var repeatEmail: String = ""
    @State private var password: String = ""
    @State private var emailError: String? = nil
    @State private var repeatEmailError: String? = nil
    @State private var passwordError: String? = nil
    @AppStorage("uid") var userID: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack(spacing: 0) {
            topSheet
            customTextFields
            bottomSection
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    router.navigateBack()
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
    
    private var topSheet: some View {
        VStack(spacing: 5) {
            Text("Create an Account!")
                .foregroundColor(.black)
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("We need your email and password to create an account")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var customTextFields: some View {
        VStack(spacing: 6) {
            CustomTextField(icon: "pawprint", placeholder: "Email", text: $email)
                .padding(.bottom, 4)
            if let emailError = emailError {
                Text(emailError)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            CustomTextField(icon: "pawprint", placeholder: "Repeat email", text: $repeatEmail)
                .padding(.bottom, 4)
            if let repeatEmailError = repeatEmailError {
                Text(repeatEmailError)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            CustomSecureField(icon: "lock", placeholder: "Password", text: $password)
            if let passwordError = passwordError {
                Text(passwordError)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

        }
        .padding(.horizontal, 20)
        .padding(.top, 13)
    }
    
    private var bottomSection: some View {
        Button {
            validateFields()
            if emailError == nil && passwordError == nil {
                registerUser()
            }
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text("Create")
                        .foregroundColor(.black)
                        .font(.system(size: 17))
                        .bold()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical)
        .disabled(isLoading)
    }
    
    private func validateFields() {
        if email.isEmpty {
            emailError = "Email is required"
        } else if !isValidEmail(email) {
            emailError = "Invalid email format."
        } else {
            emailError = nil
        }
        
        if repeatEmail.isEmpty {
            repeatEmailError = "Empty field"
        } else if !isValidEmail(repeatEmail) {
            repeatEmailError = "Invalid email format."
        } else {
            repeatEmailError = nil
        }
        
        if password.isEmpty {
            passwordError = "Password is required"
        } else if !isValidPassword(password) {
            passwordError = "Password must be at least 6 characters, contain an uppercase letter and special character."
        } else {
            passwordError = nil
        }
    }
    
    private func registerUser() {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let authResult = authResult {
                print(authResult.user.uid)
                userID = authResult.user.uid
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = NSPredicate(format: "SELF MATCHES %@", "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$")
        return emailRegex.evaluate(with: email.uppercased())
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        return passwordRegex.evaluate(with: password)
    }
}


#Preview {
    SignUpView()
}
