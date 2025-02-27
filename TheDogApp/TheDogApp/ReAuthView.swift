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
    @State private var password = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @EnvironmentObject var router: Router
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    Text("Confirm to delete account")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Please enter your password to delete your account").font(.system(size: 16)).foregroundStyle(Color.white).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 3).bold()
                    
                    CustomSecureField(icon: "lock", placeholder: "Enter password", text: $password)
                    
                    Button("Delete") {
                        reauthenticateWithEmail()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Text("In case you logged in with Google account").font(.system(size: 16)).foregroundStyle(Color.white).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 14).bold()
                    
                    Button("Delete auth with Google") {
                        reauthenticateWithGoogle()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .background(
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
            
            if isLoading {
                ZStack {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Deleting...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(30)
                    .background(Color.gray)
                    .cornerRadius(12)
                }
                .transition(.opacity)
            }
        }
    }

    func reauthenticateWithEmail() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in"
            showErrorAlert = true
            return
        }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
            user.reauthenticate(with: credential) { result, error in
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    showErrorAlert = true
                } else {
                    deleteAccount()
                }
            }
        }
    }

    func reauthenticateWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "No client ID found"
            showErrorAlert = true
            return
        }
        
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            errorMessage = "No root view controller"
            showErrorAlert = true
            return
        }

        _ = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                errorMessage = "Google sign-in failed: \(error.localizedDescription)"
                showErrorAlert = true
                return
            }

            guard let user = result?.user, let idToken = user.idToken else {
                errorMessage = "Invalid Google credentials"
                showErrorAlert = true
                return
            }
            
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)

                Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
                    isLoading = false
                    if let error = error {
                        errorMessage = "Error: \(error.localizedDescription)"
                        showErrorAlert = true
                    } else {
                        deleteAccount()
                    }
                }
            }
        }
    }

    func deleteAccount() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                errorMessage = "Failed to delete account: \(error.localizedDescription)"
                showErrorAlert = true
            } else {
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                router.navigateToRoot()
                router.navigate(to: .loginView)
            }
        }
    }
}

