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
//        var what3Words: String
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


//struct User: Decodable {
//  enum CodingKeys: String, CodingKey {
//    case id, fullName, isRegistered, email
//  }
//
//  let id: Int
//  let fullName: String
//  let isRegistered: Bool
//  let email: String
//
//  init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    self.id = try container.decode(Int.self, forKey: .id)
//    self.fullName = try container.decode(String.self, forKey: .fullName)
//    self.isRegistered = try container.decodeIfPresent(Bool.self, forKey: .isRegistered) ?? false
//    self.email = try container.decode(String.self, forKey: .email)
//  }
//}



//{
//  "id": "jncq",
//  "resource": "point",
//  "name": "Baltimore Yacht Club",
//  "kind": "marina",
//  "rating": null,
//  "review_count": 0,
//  "location": {
//    "lat": 39.28783449044417,
//    "lon": -76.39857580839772,
//    "what3words": "figs.ongoing.hesitating"
//  },
//  "images": {
//    "resource": "list",
//    "data": [
//
//    ],
//    "total_count": 0
//  },
//  "web_url": "https://marinas.com/view/marina/jncq_Baltimore_Yacht_Club_Essex_MD_United_States",
//  "api_url": "https://api.marinas.com/v1/marinas/jncq",
//  "icon_url": "https://marinas.com/assets/map/marker_marina-61b3ca5ea8e7fab4eef2d25df94457f060498ca1a72e3981715f46d2ab347db4.svg",
//  "fuel": {
//    "has_diesel": true,
//    "has_propane": false,
//    "has_gas": true,
//    "propane_price": null,
//    "diesel_price": null,
//    "gas_regular_price": null,
//    "gas_super_price": null,
//    "gas_premium_price": null
//  },
//  "icon_urls": {
//    "light": "https://marinas.com/assets/map/light/marker_marina-5010a82e1bce7bf8a225fe4d19cf9befa9acea1997dd43fcb46703722810b3a3.svg",
//    "regular": "https://marinas.com/assets/map/marker_marina-61b3ca5ea8e7fab4eef2d25df94457f060498ca1a72e3981715f46d2ab347db4.svg",
//    "dark": "https://marinas.com/assets/map/dark/marker_marina-813d72233e076185a2c77761f802728ced60cc0e72044871c1c15f0b9c0bcf58.svg"
//  }
//}
