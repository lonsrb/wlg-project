//
//  PointViewModel.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation
import Combine
import UIKit.UIImage

class PointViewModel : ObservableObject, Identifiable {
    var nameString : String
    var latString : String
    var lonString : String
    var kindString: String
    var iconUrl: String
    var siteUrl: String
    
    @Published var thumbnailImage: UIImage = UIImage(systemName: "ellipsis",
                                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 55, weight: .black))!
    
    private(set) var point: Point
    private var pointsService : PointsServiceProtocol!
    
    
    init(point : Point, pointsService : PointsServiceProtocol) {
        self.point = point
        self.pointsService = pointsService
        
        nameString = point.name
        latString = "lat: " + String(point.location.lat)
        lonString = "lon: " + String(point.location.lon)
        kindString = point.kind.rawValue
        iconUrl = point.iconUrl
        siteUrl = point.webUrl
        //        populateCell()
    }
    
//    func populateCell() {
//        nameString = point.name
//        latString = String(point.location.lat)
//        lonString = String(point.location.lon)
//        kindString = point.kind.rawValue
//    }
    
    @MainActor func loadImage() async -> UIImage {
        do {
            if let iconImage = try await pointsService.loadPointIcon(thumbnailURL: point.iconUrl) {
                thumbnailImage = iconImage
            }
        }
        catch {
            //for now do nothing with the error, ideally we'd have
            //analytics to track these internal kinds of errors
        }
        return self.thumbnailImage
    }
}
