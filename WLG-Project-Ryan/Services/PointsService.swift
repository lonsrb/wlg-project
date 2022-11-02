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
    
    func centerMapContextAroundPoint(coord : CLLocationCoordinate2D)
    func loadPoints(searchContext: SearchContext) async
    func loadImage(thumbnailURL : String) async throws -> UIImage?
    func tryLoadImageFromCache(thumbnailURL : String) -> UIImage?
}

struct PointsResponse: Codable {
    let data: [Point]
}

class PointsService: PointsServiceProtocol {
    var pointsSubject = PassthroughSubject<[Point], Never>()
    var searchContextSubject = PassthroughSubject<SearchContext, Never>()
    var cachedSearchContext: SearchContext = SearchContext(query: "", selectedFilters: [], region: MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.28783449044417, longitude: -76.39857580839772),
        latitudinalMeters: 2000,
        longitudinalMeters: 2000
    )){
        didSet {
            searchContextSubject.send(cachedSearchContext)
        }
    }
    
    private var loadingPoints = false
    private var currentPoints = [Point]()
    private var networkingService : NetworkingServiceProtocol!
    
    init(networkingService : NetworkingServiceProtocol) {
        self.networkingService = networkingService
    }
    
    //this function updates the local search context cache given a new point
    //this is used when some part of the app wants a location to be centered
    //on the map while not activley using the map
    func centerMapContextAroundPoint(coord : CLLocationCoordinate2D) {
        var region: MKCoordinateRegion
        if let cachedRegion = cachedSearchContext.region {
            region = MKCoordinateRegion(center: coord, span: cachedRegion.span)
        }
        else {
            region = MKCoordinateRegion(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000)
        }
        
        cachedSearchContext = SearchContext(query: cachedSearchContext.query,
                                            selectedFilters: cachedSearchContext.selectedFilters,
                                            region: region)
    }
    
    func loadPoints(searchContext: SearchContext) async {
        guard loadingPoints == false else { return } //debounce loading
        
        guard let urlComponents = NSURLComponents(string: ApplicationConfiguration.hostUrl + Endpoints.pointsSearch) else {
            assertionFailure("we control the URL, it should make sense and never be nil here")
            return
        }
        
        var queryItems: [URLQueryItem] = [URLQueryItem]()
        
        //set the search region if we have it
        if let region = searchContext.region {
            let latitude = region.center.latitude
            let longitude = region.center.longitude
            let northEdgeOfMap = region.center.latitude + region.span.latitudeDelta/2
            let southEdgeOfMap = region.center.latitude - region.span.latitudeDelta/2
            let westEdgeOfMap = region.center.longitude - region.span.longitudeDelta/2
            let eastEdgeOfMap = region.center.longitude + region.span.longitudeDelta/2
            
            queryItems = [URLQueryItem(name: "location[lat]", value: String(latitude)),
                          URLQueryItem(name: "location[lon]", value: String(longitude)),
                          URLQueryItem(name: "bounds[ne][lat]", value: String(northEdgeOfMap)),
                          URLQueryItem(name: "bounds[ne][lon]", value: String(eastEdgeOfMap)),
                          URLQueryItem(name: "bounds[sw][lat]", value: String(southEdgeOfMap)),
                          URLQueryItem(name: "bounds[sw][lon]", value: String(westEdgeOfMap))]
        }
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
            loadingPoints = true
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            //for debugging unexpected json response
            //            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
            //                print(JSONString)
            //            }
            let pointsResponse = try decoder.decode(PointsResponse.self, from: data)
            currentPoints = pointsResponse.data
            pointsSubject.send(currentPoints)
            cachedSearchContext = searchContext
            loadingPoints = false
        }
        catch {
            loadingPoints = false
            print("there was an error decoding the point results: \(error)")
        }
    }
    
    func tryLoadImageFromCache(thumbnailURL : String) -> UIImage? {
        if let chachedImage = ImageCache.shared.get(url: thumbnailURL) {
            return chachedImage
        }
        return nil
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
        
        //if we got this far it means somethign failed. Let's just return nil
        return nil
    }
}
