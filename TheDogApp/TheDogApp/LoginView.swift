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
    
    var body: some View {
        VStack {
            Text("The Dog App")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 15)
                .foregroundStyle(Color.black)
            
            Image("whitedog")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
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
            
            HStack {
                Button {
                    if viewModel.email.isEmpty || viewModel.password.isEmpty {
                        viewModel.errorMessage = "Please enter both email and password."
                        return
                    }
                    
                    viewModel.signIn { success in
                        if success {
                            saveSession()
                            withAnimation {
                                showMainListView = true
                            }
                        } else {
                            viewModel.errorMessage = "Please verify your credentials."
                        }
                    }
                } label: {
                    Text("Login")
                        .foregroundColor(.black)
                        .font(.title3)
                        .bold()
                        .frame(height: 45)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fullScreenCover(isPresented: $showMainListView){
                            MainListView(viewModel: DogViewModel())
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            
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
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Scan to authenticate please"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        withAnimation {
                            showMainListView = true
                        }
                    } else {
                        viewModel.errorMessage = "Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")"
                    }
                }
            }
        } else {
            viewModel.errorMessage = "Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
    
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                viewModel.errorMessage = "Failed to retrieve Google credentials."
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    viewModel.errorMessage = "Firebase Sign-In failed: \(error.localizedDescription)"
                    return
                }
                
                saveSession()
                withAnimation {
                    showMainListView = true
                }
            }
        }
    }
    
    private func saveSession() {
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
    }
    
    private func checkSession() {
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") {
            authenticate()
        } else {
            UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
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
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 15)

            SecureField(placeholder, text: $text)
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

#Preview {
    LoginView()
}
