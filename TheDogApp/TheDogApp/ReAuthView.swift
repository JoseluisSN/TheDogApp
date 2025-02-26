//
//  ReAuthView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 26/02/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

struct ReAuthView: View {
    
    @Environment(\.dismiss) var dismiss
    var onSuccess: (() -> Void)? = nil
    
    @State private var email = ""
    @State private var password = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @EnvironmentObject var router: Router

    var body: some View {
        NavigationView {
            VStack {
                Text("Confirm to delete account")
                    .font(.title)
                    .bold()
            
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16).frame(height: 65)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16).frame(height: 65)
                
                Button("Delete") {
                    reauthenticateWithEmail()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                
                Button("Delete auth with Google") {
                    reauthenticateWithGoogle()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                
                Spacer()
            }.background(
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.black]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }.navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        router.navigateBack()
                    }) {
                        Image(systemName: "chevron.left").foregroundStyle(Color.black)
                    }
                }
            }
    }

    func reauthenticateWithEmail() {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
                showErrorAlert = true
            } else {
                dismiss()
                (onSuccess)
            }
        }
    }

    func reauthenticateWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        _ = GIDConfiguration(clientID: clientID)
        
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
                showErrorAlert = true
                return
            }
            
            guard let user = Auth.auth().currentUser, let idToken = result?.user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result?.user.accessToken.tokenString ?? "")
            
            user.reauthenticate(with: credential) { result, error in
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    showErrorAlert = true
                } else {
                    dismiss()
                    onSuccess!()
                }
            }
        }
    }
}
