//
//  PointsService.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation
import UIKit.UIImage
import Combine
import CoreLocation
import SwiftDraw

protocol PointsServiceProtocol {
    var pointsSubject: PassthroughSubject<[Point], Never> { get }
    func loadPoints(coordinate: CLLocationCoordinate2D) async
    func loadPointIcon(thumbnailURL : String) async throws -> UIImage?
}

struct PointsResponse: Codable {
    let resource: String
    let data: [Point]
}

class PointsService: PointsServiceProtocol {
    
    var pointsSubject = PassthroughSubject<[Point], Never>()
    
    private var currentPoints = [Point]()
    private var networkingService : NetworkingServiceProtocol!
    
    init(networkingService : NetworkingServiceProtocol) {
        self.networkingService = networkingService
    }
        
    func loadPoints(coordinate: CLLocationCoordinate2D) async {
        
        guard let urlComponents = NSURLComponents(string: ApplicationConfiguration.hostUrl + Endpoints.pointsSearch) else {
            assertionFailure("we control the URL, it should make sense and never be nil here")
            return
        }
        let queryItems = [URLQueryItem(name: "location[lat]", value: String(coordinate.latitude)),
                          URLQueryItem(name: "location[lon]", value: String(coordinate.longitude))]
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            assertionFailure() //we control the URL, it should make sense and never be nil here
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let pointsResponse = try decoder.decode(PointsResponse.self, from: data)
            currentPoints = pointsResponse.data
            pointsSubject.send(currentPoints)
        }
        catch {
            print("there was an error decoding the point results: \(error)")
        }
    }
    
    //Load the Icon for the point. Use the cache if the image is in there otherwise download.
    //We're using 3rd parth lib to be able to do `UIImage(svgData: data)`
    func loadPointIcon(thumbnailURL : String) async throws -> UIImage? {
        
        //used cached image if we can
        if let chachedImage = ImageCache.shared.get(url: thumbnailURL) {
            return chachedImage
        }
        
        //ensure valid url
        guard let url = URL(string: thumbnailURL) else {
            throw NetworkingError.invalidUrl(thumbnailURL)
        }
        
        //download contents of the svg url
        do {
            let data = try Data(contentsOf:url)
            if let image = UIImage(svgData: data) {
                ImageCache.shared.set(url: thumbnailURL, image: image)
                return image
            }
        }
        catch {
            print("error parsing svg image data: \(error)")
        }
        
        //if we got this far it means somethign failed. Lets just return a placeholder.
        let configuration = UIImage.SymbolConfiguration(pointSize: 55, weight: .black)
        let placeHolder = UIImage(systemName: "ellipsis", withConfiguration: configuration)
        return placeHolder
    }
}
