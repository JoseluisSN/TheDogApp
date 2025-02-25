//
//  ProfileView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 25/02/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ProfileView: View {
    @EnvironmentObject var router: Router
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text("Account")
                    .font(.system(size: 38, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Image("profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 140)
                    .clipShape(Circle())

                Text("Joseluis Sancho Navarro")
                    .font(.title)
                    .bold()

                Text("luisnavarro280502@")
                    .font(.subheadline)
                    .foregroundColor(.black)

                Text("Peru")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            buttons
            
            // PASAMOS LA UBICACIÓN AL MAPVIEW
            MapView(userLocation: locationManager.userLocation)
                .frame(height: 150)
                .cornerRadius(12)
                .padding()

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    router.navigateBack()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
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

var buttons: some View {
    VStack {
        Button(action: {
            
        }) {
            HStack {
                Spacer()
                Text("History")
                    .font(.headline)
                Image(systemName: "cart")
                Spacer()
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(.systemGray5))
            .foregroundColor(.black)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
        
        Button(action: {
            
        }) {
            HStack {
                Spacer()
                Text("Update account")
                    .font(.headline)
                Image(systemName: "slider.horizontal.3")
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
