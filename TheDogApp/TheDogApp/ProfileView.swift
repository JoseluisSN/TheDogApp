//
//  ProfileView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 25/02/25.
//

import SwiftUI
import MapKit
import LocalAuthentication
import FirebaseAuth
import CoreLocation
import GoogleSignIn
import FirebaseCore

struct ProfileView: View {
    @EnvironmentObject var router: Router
    @StateObject private var locationManager = LocationManager()
    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showReAuthView = false
    
    var body: some View {
        NavigationView {
            VStack {
                texts
                buttons()
                Button(action: logOut) {
                    Text("Log out")
                        .foregroundColor(.white)
                        .frame(height: 45)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                        )
                        .padding(.horizontal, 16)
                }
                MapView(userLocation: locationManager.userLocation)
                    .frame(height: 150)
                    .cornerRadius(12)
                    .padding()
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("¿Estás seguro?", isPresented: $showDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    router.navigate(to: .reauthView)
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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

    func logOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
            router.navigateToRoot()
            router.navigate(to: .loginView)
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }

    func deleteUser() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete { error in
            if let error = error {
                errorMessage = "Error al eliminar la cuenta: \(error.localizedDescription)"
                showErrorAlert = true
            } else {
                try? Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                router.navigateToRoot()
                router.navigate(to: .loginView)
            }
        }
    }

    func buttons() -> some View {
        VStack {
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack {
                    Spacer()
                    Text("Delete account")
                        .font(.headline)
                    Image(systemName: "xmark")
                    Spacer()
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(.systemGray5))
                .foregroundColor(.black)
                .cornerRadius(12)
                .padding(.horizontal, 16)
            }
        }
    }
}

var texts: some View {
    VStack(spacing: 0) {
        Text("Account")
            .font(.system(size: 36, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        
        Image("profile")
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 140)
        
        Text("Joseluis Sancho Navarro")
            .font(.title2)
        
        Text("luisnavarro280502@")
            .font(.subheadline)
            .foregroundColor(.black)
        
        Text("Peru")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
            }
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
