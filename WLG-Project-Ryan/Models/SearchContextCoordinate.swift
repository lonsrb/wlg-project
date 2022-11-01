//
//  SearchContextCoordinate.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/30/22.
//

import Foundation
import CoreLocation
import MapKit

class SearchContext: ObservableObject {
//    var latitude: CLLocationDegrees = 39.28783449044417//0.0
//    var longitude: CLLocationDegrees = -76.39857580839772//0.0
    var query: String = ""
    var selectedFilters: [PointType] = [PointType]()
    
    var region : MKCoordinateRegion
    
//    var region : MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 39.28783449044417, longitude: -76.39857580839772),
//        latitudinalMeters: 750,
//        longitudinalMeters: 750
//    )
    
    var coordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
        }
//        set(value) {
////            latitude = value.latitude
////            longitude = value.longitude
//            region.center = value
//        }
    }
    
    init(query: String, selectedFilters: [PointType], region: MKCoordinateRegion) {
        self.query = query
        self.selectedFilters = selectedFilters
        self.region = region
    }
}
