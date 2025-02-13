//
//  LoginViewModel.swift
//  TheDogApp
//
//  Created by Joseluis SN on 12/02/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class LoginViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @AppStorage("uid") var userID: String = ""

    func signIn(completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
