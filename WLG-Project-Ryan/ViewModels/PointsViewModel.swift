//
//  PointsViewModel.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation
import Combine
import CoreLocation
import MapKit

class PointsViewModel: ObservableObject  {
    @Published var points: [PointViewModel] = []
    @Published var resultCountString: String = ""
    @Published var isSearching = false
    @Published var searchContext: SearchContext!
    
    var pointsService : PointsServiceProtocol!
    
    private var cancellables = Set<AnyCancellable>()
    
    init(pointsService : PointsServiceProtocol) {
        self.pointsService = pointsService
        searchContext = self.pointsService.cachedSearchContext
        
        pointsService.searchContextSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newSearchContext in
                guard let self = self else { return }
                Just(newSearchContext).assign(to: &self.$searchContext)
            })
            .store(in: &cancellables)
        
        pointsService.pointsSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pointModels in
                guard let self = self else { return }
                
                let newPoints = pointModels.map { PointViewModel(point: $0, pointsService: self.pointsService) }
                
                let countString = "\(newPoints.count) result\(newPoints.count != 1 ? "s" : "")"
                Just(countString).assign(to: &self.$resultCountString)
                Just(newPoints).assign(to: &self.$points)
            })
            .store(in: &cancellables)
    }
    
    @MainActor func reloadPointsIfNeeded(newRegion: MKCoordinateRegion){
        let currentCoord = pointsService.cachedSearchContext.coordinate
        let currentLocation = CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude)
        
        let newLocation = CLLocation(latitude: newRegion.center.latitude, longitude: newRegion.center.longitude)
        let distance = currentLocation.distance(from: newLocation)
        print("---- distance is: \(distance)")
        if distance > 5000 {//5000 meters, total arbitraty at this point. should eventually be with regard to map window scale
            searchForPoints(coordinate: newRegion.center, queryString: pointsService.cachedSearchContext.query, selectedFilters: pointsService.cachedSearchContext.selectedFilters)
        }
//        pointsService.cachedSearchContext.region.center = newRegion.center
        
//        bounds | optional
//        ne
//        lat
//        number greater than or equal to -90 and less than or equal to 90
//        lon
//        number greater than or equal to -180 and less than or equal to 180
//        sw
//        lat
//        number greater than or equal to -90 and less than or equal to 90
//        lon
//        number greater than or equal to -180 and less than or equal to 180

    }
    
    @MainActor
    func searchForPoints(coordinate: CLLocationCoordinate2D?, queryString: String, selectedFilters: [PointType]) {
        Task {
            isSearching = true
            let coord = coordinate ?? pointsService.cachedSearchContext.coordinate
            let context = SearchContext(query: queryString,
                                        selectedFilters: selectedFilters,
                                        region: MKCoordinateRegion(center: coord, latitudinalMeters: 750, longitudinalMeters: 750))
            
            await pointsService.loadPoints(searchContext: context)
            isSearching = false
        }
    }
}
