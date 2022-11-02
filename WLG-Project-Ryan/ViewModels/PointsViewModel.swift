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
    
    @MainActor func reloadPointsIfNeeded(newRegion: MKCoordinateRegion) {
        
        //if no cached region then definily need to load points for this region
        guard let cachedRegion = pointsService.cachedSearchContext.region else {
            searchForPoints(region: newRegion,
                            queryString: pointsService.cachedSearchContext.query,
                            selectedFilters: pointsService.cachedSearchContext.selectedFilters)
            return
        }
        
        //calculate the distance between this point and the last one we pulled data for
        let currentLocation = CLLocation(latitude: cachedRegion.center.latitude,
                                         longitude: cachedRegion.center.longitude)
        
        let newLocation = CLLocation(latitude: newRegion.center.latitude, longitude: newRegion.center.longitude)
        let distance = currentLocation.distance(from: newLocation)
        
        //calculate the current zoom level
        let westEdgeLocation = CLLocation(latitude: newRegion.center.latitude,
                                          longitude: newRegion.center.longitude - newRegion.span.longitudeDelta/2)
        let distanceFromCenterOfMapToEdge = newLocation.distance(from: westEdgeLocation)
        
        //cut off to 4 decimal places which is 11.1m of latitude
        //span is the amount of map shown on screen aka zoom
        let newSpan = (newRegion.span.latitudeDelta * 10000).rounded() / 10000
        let currentSpan = (cachedRegion.span.latitudeDelta * 10000).rounded() / 10000
        let zoomDelta = abs(newSpan - currentSpan)
        
        //2 conditions that'd make use ask for new points
        //    1: the map window moved a certain distance
        //    2: the map window changed zoom a certain amount
        if zoomDelta > 0.01 || distance > distanceFromCenterOfMapToEdge { //0.01 is ~1km of distance, kind of arbitrary
            searchForPoints(region: newRegion, queryString: pointsService.cachedSearchContext.query, selectedFilters: pointsService.cachedSearchContext.selectedFilters)
        }
    }
    
    func centerMapAtPoint(pointViewModel: PointViewModel) {
        pointsService.centerMapContextAroundPoint(coord: pointViewModel.coord)
    }
    
    @MainActor
    func searchForPoints(region: MKCoordinateRegion?, queryString: String, selectedFilters: [PointType]) {
        Task {
            isSearching = true
            let context = SearchContext(query: queryString,
                                        selectedFilters: selectedFilters,
                                        region: region)
            
            await pointsService.loadPoints(searchContext: context)
            isSearching = false
        }
    }
}
