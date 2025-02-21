//
//  TheDogAppApp.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//

import SwiftUI
import Firebase
import FirebaseCore

@main
struct TheDogAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
      }
    }

    
    @StateObject var router = Router()
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) {
                LoginView().preferredColorScheme(.light)
                    .navigationDestination(for: Router.Destination.self) { destination in
                        switch destination {
                        case .mainListView:
                            MainListView(viewModel: DogViewModel()).preferredColorScheme(.light)
                        case .registerView:
                            SignUpView().preferredColorScheme(.light)
                        case .loginView:
                            LoginView().preferredColorScheme(.light)
                        case .settingsView:
                            SettingsView().preferredColorScheme(.light)
                        }
                    }
            }
            .environmentObject(router)
        }
        
    }
}
