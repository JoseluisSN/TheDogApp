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
    @State public var email: String = ""
    @State public var name: String = ""
    @State private var photoURL: URL? = nil
    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showReAuthView = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    VStack(spacing: 0) {
                        Text("Account")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                        
                        AsyncImage(url: photoURL) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 140, height: 120)
                        .clipShape(Circle())
                        .padding(.top, 10)
                        
                        Text(name)
                            .font(.title2).padding(.top, 10)
                        
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Text(locationManager.country)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.top, 3)
                    }
                    
                    button()
                    
                    Button(action: logOut) {
                        HStack {
                            Spacer()
                            Text("Log out")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Spacer()
                        }
                        .frame(height: 50)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                    }.disabled(isLoading)
                    
                    MapView(userLocation: locationManager.userLocation?.coordinate)
                        .frame(height: 150)
                        .cornerRadius(12)
                        .padding()
                    Spacer()
                }
                .navigationBarHidden(true)
                .alert("are you sure?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        router.navigate(to: .reauthView)
                    }
                } message: {
                    Text("This action cannot be undone.")
                }
                .alert("Error", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .onAppear {
                    if let user = Auth.auth().currentUser {
                        email = user.email ?? "No email"
                        name = user.displayName ?? "No name"
                        photoURL = user.photoURL
                    }
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
            
            if isLoading {
                ZStack {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Login out...")
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

    func logOut() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                UserDefaults.standard.removeObject(forKey: "biometricEnabled")
                isLoading = false
                router.navigateToRoot()
                router.navigate(to: .loginView)
            } catch {
                print("Error al cerrar sesión: \(error.localizedDescription)")
            }
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

    func button() -> some View {
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

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var country: String = "Unknown"

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
        fetchCountry(from: location)
    }

    private func fetchCountry(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.country = placemark.country ?? "Unknown"
                }
            }
        }
    }
}


extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
