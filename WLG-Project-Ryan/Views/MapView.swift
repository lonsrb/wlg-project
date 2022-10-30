//
//  MapView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/29/22.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var pointViewModel: PointsViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
    
    var body: some View {
        Map(coordinateRegion: $region)
            .onAppear{
                setRegionForCoord(coord: pointViewModel.searchCoordinate)
            }
    }
    
    private func setRegionForCoord(coord: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: pointViewModel.searchCoordinate,
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
    }
}
  
