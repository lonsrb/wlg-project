//
//  Point.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation
import CoreLocation

struct Point: Codable{
    struct Location: Codable {
        var lat: Double
        var lon: Double
    }
    
    struct Images: Codable {
        var resource: String
        var data: [Image]
        var totalCount: Int
        
        struct Image: Codable {
            var resource: String
            var smallUrl: String
        }
    }
    
    var id: String
    var name: String
    var kind: PointType
    var rating: String?
    var reviewCount: Int
    var location: Location
    var images: Images
    var webUrl: String
    var apiUrl: String
    var iconUrl: String
    
    internal init(id: String, name: String, kind: PointType, rating: String?,
                  reviewCount: Int, location: Point.Location, images: Point.Images,
                  webUrl: String, apiUrl: String, iconUrl: String) {
        self.id = id
        self.name = name
        self.kind = kind
        self.rating = rating
        self.reviewCount = reviewCount
        self.location = location
        self.images = images
        self.webUrl = webUrl
        self.apiUrl = apiUrl
        self.iconUrl = iconUrl
    }
}
