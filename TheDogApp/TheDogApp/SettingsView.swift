//
//  SettingsView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 14/02/25.
//

import SwiftUI
import LocalAuthentication
import FirebaseAuth

struct SettingsView: View {
    @State private var isBiometricEnabled = false
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.system(size: 38, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                Toggle("Biometric Authentication", isOn: Binding(
                    get: { UserDefaults.standard.bool(forKey: "biometricEnabled") },
                    set: { newValue in
                        UserDefaults.standard.set(newValue, forKey: "biometricEnabled")
                    }
                ))
                .padding(.horizontal, 16)
                .font(.system(size: 20))
                
                Button(action: logOut) {
                   Text("Log out")
                       .foregroundColor(.white)
                       .frame(width: 80, height: 30)
                       .bold()
                       .background(
                           RoundedRectangle(cornerRadius:7)
                               .fill(Color.black)
                       )
                       .padding(.horizontal, 16)
               }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
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
    
    private func logOut() {
        do {
            isBiometricEnabled = false
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                router.navigateToRoot()
                router.navigate(to: .loginView)
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
