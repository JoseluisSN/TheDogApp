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
                .foregroundStyle(.black)
            
            Image("whitedog")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
            CustomTextField(icon: "pawprint", placeholder: "Email", text: $viewModel.email)
                .padding(.bottom, 4)
            
            CustomSecureField(icon: "lock", placeholder: "Password", text: $viewModel.password)
            
            Text("Are you new? SignUp")
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .padding(.bottom, 18)
                .onTapGesture {
                    router.navigate(to: .registerView)
                }
            
            Button {
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config
                
                GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
                    guard error == nil else {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    
                    guard let user = result?.user,
                          let idToken = user.idToken?.tokenString else {
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: user.accessToken.tokenString)
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            return
                        }
                        
                        withAnimation {
                            showMainListView = true
                        }
                    }
                }
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
                        Auth.auth().signIn(withEmail: viewModel.email, password: viewModel.password) { authResult, error in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                                return
                            }
                            if let authResult = authResult {
                                print("User ID: \(authResult.user.uid)")
                                viewModel.userID = authResult.user.uid
                                withAnimation {
                                    showMainListView = true
                                }
                            }
                        }
                    } label: {
                        Text("Login")
                            .foregroundColor(.black)
                            .font(.title3)
                            .bold()
                            .frame(height: 45)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                            )
                    }
                    
                    Spacer()
                    
                    Button {
                        authenticate()
                    } label: {
                        HStack {
                            Image(systemName: "faceid")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(width: 45 ,height: 45)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .fullScreenCover(isPresented: $showMainListView) {
                        MainListView(viewModel: DogViewModel())
                    }
                
            }.frame(maxWidth: .infinity)

            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Scan your face to authenticate"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        withAnimation {
                            showMainListView = true
                        }
                    } else {
                        print("Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
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
