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
import MapKit

protocol PointsServiceProtocol {
    var pointsSubject: PassthroughSubject<[Point], Never> { get }
    var cachedSearchContext: SearchContext { get }
    var searchContextSubject: PassthroughSubject<SearchContext, Never> { get }
    
    func loadPoints(searchContext: SearchContext) async
    func loadImage(thumbnailURL : String) async throws -> UIImage?
}

struct PointsResponse: Codable {
    let data: [Point]
}

class PointsService: PointsServiceProtocol {
    var pointsSubject = PassthroughSubject<[Point], Never>()
    var searchContextSubject = PassthroughSubject<SearchContext, Never>() {
        didSet {
            print("seting new search context")
            searchContextSubject.send(cachedSearchContext)
        }
    }
    var cachedSearchContext: SearchContext = SearchContext(query: "", selectedFilters: [], region: MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.28783449044417, longitude: -76.39857580839772),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    ))
    
    private var currentPoints = [Point]()
    private var networkingService : NetworkingServiceProtocol!
    
    init(networkingService : NetworkingServiceProtocol) {
        self.networkingService = networkingService
    }
    
    func loadPoints(searchContext: SearchContext) async {
        
        guard let urlComponents = NSURLComponents(string: ApplicationConfiguration.hostUrl + Endpoints.pointsSearch) else {
            assertionFailure("we control the URL, it should make sense and never be nil here")
            return
        }
        var queryItems = [URLQueryItem(name: "location[lat]", value: String(searchContext.coordinate.latitude)),
                          URLQueryItem(name: "location[lon]", value: String(searchContext.coordinate.longitude))]
        
        if searchContext.query.count > 0 {
            let filterQueryItem = URLQueryItem(name: "query", value: searchContext.query)
            queryItems.append(filterQueryItem)
        }
        
        if searchContext.selectedFilters.count > 0 {
            let stringArray = searchContext.selectedFilters.map{ $0.rawValue }
            let stringValue = stringArray.joined(separator: ",")
            let filterQueryItem = URLQueryItem(name: "kind", value: stringValue)//also tried markers
            queryItems.append(filterQueryItem)
        }
        
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
            //            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
            //                       print(JSONString)
            //            }
            let pointsResponse = try decoder.decode(PointsResponse.self, from: data)
            currentPoints = pointsResponse.data
            pointsSubject.send(currentPoints)
            cachedSearchContext = searchContext
        }
        catch {
            print("there was an error decoding the point results: \(error)")
        }
    }
    
    //Load the an Image for a point. Use the cache if the image is in there otherwise download.
    //We're using 3rd parth lib to be able to do deserialize svgs, eg: `UIImage(svgData: data)`
    func loadImage(thumbnailURL : String) async throws -> UIImage? {
        
        //used cached image if we can
        if let chachedImage = ImageCache.shared.get(url: thumbnailURL) {
            return chachedImage
        }
        
        //ensure valid url
        guard let url = URL(string: thumbnailURL) else {
            throw NetworkingError.invalidUrl(thumbnailURL)
        }
        
        //download contents of the url
        do {
            let data = try Data(contentsOf:url)
            
            //if the url is for SVG
            if thumbnailURL.contains(".svg") {
                if let image = UIImage(svgData: data) {
                    ImageCache.shared.set(url: thumbnailURL, image: image)
                    return image
                }
            }
            else { //"normal" image
                if let image = UIImage(data: data) {
                    ImageCache.shared.set(url: thumbnailURL, image: image)
                    return image
                }
            }
            
        }
        catch {
            print("Error parsing svg image data: \(error)")
        }
        
        //if we got this far it means somethign failed. Lets just return nil
        return nil
    }
}
