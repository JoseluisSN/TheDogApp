//
//  LoginView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 12/02/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import Firebase
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var router: Router
    @StateObject private var viewModel = LoginViewModel()
    @State private var showMainListView = false
    @State private var isUnlocked = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    topSheet
                    customFields
                    bottomSheet
                    Spacer()
                }
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.white, Color.black]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                )
                .onAppear {
                    checkSession()
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            
            if isLoading {
                ZStack {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Loading...")
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
    
    private var customFields: some View {
        VStack {
            CustomTextField(icon: "pawprint", placeholder: "Email", text: $viewModel.email)
                .padding(.bottom, 4)
            
            CustomSecureField(icon: "lock", placeholder: "Password", text: $viewModel.password)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text("Are you new? SignUp")
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .padding(.top, 18)
                .onTapGesture {
                    router.navigate(to: .registerView)
                }
        }
    }
    
    private var topSheet: some View {
        VStack {
            Text("The Dog App")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 15)
                .foregroundStyle(Color.black)
            
            Image("whitedog")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
        }
    }
    
    private var bottomSheet: some View {
        VStack {
            Button {
                signInWithGoogle()
            } label: {
                HStack {
                    Image("googleOne")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    Text("Iniciar con Google")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(height: 45)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
            
            HStack {
                Button {
                    if viewModel.email.isEmpty || viewModel.password.isEmpty {
                        viewModel.errorMessage = "Please enter both email and password."
                        return
                    }
                    
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        viewModel.signIn { success in
                            isLoading = false
                            if success {
                                saveSession()
                                withAnimation {
                                    router.navigateToRoot()
                                    router.navigate(to: .mainListView)
                                }
                            } else {
                                viewModel.errorMessage = "Please verify your credentials."
                            }
                        }
                    }
                } label: {
                    Text("Login")
                        .foregroundColor(.black)
                        .font(.title3)
                        .bold()
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Scan to authenticate please"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        viewModel.errorMessage = "Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")"
                        completion(false)
                    }
                }
            }
        } else {
            viewModel.errorMessage = "Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")"
            completion(false)
        }
    }
    
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
            guard error == nil else {
                viewModel.errorMessage = "Google Sign-In canceled"
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                viewModel.errorMessage = "Failed to retrieve Google credentials."
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            withAnimation {
                isLoading = true
            }
            Auth.auth().signIn(with: credential) { authResult, error in
                isLoading = false
                if let error = error {
                    viewModel.errorMessage = "Firebase Sign-In failed: \(error.localizedDescription)"
                    return
                }
                saveSession()
                withAnimation {
                    router.navigateToRoot()
                    router.navigate(to: .mainListView)
                }
            }
        }
    }
    
    private func saveSession() {
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
    }
    
    private func checkSession() {
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") {
            let isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
            
            if isBiometricEnabled {
                authenticate { success in
                    if success {
                        withAnimation {
                            router.navigate(to: .mainListView)
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        router.navigate(to: .mainListView)
                    }
                }
            }
        }
    }
}

struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 15)
            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 15)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}


#Preview {
    LoginView()
}
