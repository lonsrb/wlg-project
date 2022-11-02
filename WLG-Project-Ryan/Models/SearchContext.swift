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
    var query: String = ""
    var selectedFilters: [PointType] = [PointType]()
    var region : MKCoordinateRegion?
    
    //convenience property
    var coordinate: CLLocationCoordinate2D? {
        get {
            guard let region = region else { return nil }
            return CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
        }
    }
    
    init(query: String, selectedFilters: [PointType], region: MKCoordinateRegion?) {
        self.query = query
        self.selectedFilters = selectedFilters
        self.region = region
    }
}
