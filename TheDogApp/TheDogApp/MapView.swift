//
//  MapView.swift
//  TheDogApp
//
//  Created by Joseluis SN on 25/02/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    var userLocation: CLLocationCoordinate2D?

    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            if let userLocation {
                Marker("Ubicación", coordinate: userLocation)
            }
        }
        .onAppear {
            if let userLoc = userLocation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: userLoc,
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                )
            }
        }
    }
}
