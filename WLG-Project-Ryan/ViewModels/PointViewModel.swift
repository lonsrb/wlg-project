//
//  PointViewModel.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation
import Combine
import UIKit.UIImage
import CoreLocation

class PointViewModel : ObservableObject, Identifiable {
    var nameString : String
    var latString : String
    var lonString : String
    var coord: CLLocationCoordinate2D
    var kindString: String
    var iconUrl: String
    var siteUrl: String
    var imageUrl: String?
    
    private(set) var point: Point
    private var pointsService : PointsServiceProtocol!
    
    
    init(point : Point, pointsService : PointsServiceProtocol) {
        self.point = point
        self.pointsService = pointsService
        
        nameString = point.name
        let location = CLLocation(latitude: point.location.lat, longitude: point.location.lon)
        
        latString = "lat: " + location.latitude
        lonString = "lon: " + location.longitude
        coord = CLLocationCoordinate2D(latitude: point.location.lat, longitude: point.location.lon)
        kindString = point.kind.rawValue.capitalized
        iconUrl = point.iconUrl
        siteUrl = point.webUrl
        imageUrl = point.images.data.first?.smallUrl
    }
    
    @MainActor func loadImage(url:String) async -> UIImage? {
        do {
            if let image = try await pointsService.loadImage(thumbnailURL: url) {
                return image
            }
        }
        catch {
            //for now do nothing with the error, ideally we'd have
            //analytics to track these internal kinds of errors
        }
        return nil
    }
}
