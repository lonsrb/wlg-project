//
//  PointsViewModel.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation
import Combine
import CoreLocation

class PointsViewModel: ObservableObject  {
    @Published var points: [PointViewModel] = []
    @Published var searchCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 39.28783449044417, longitude: -76.39857580839772)
    
    var pointsService : PointsServiceProtocol!
    
    private var cancellables = Set<AnyCancellable>()
    
    init(pointsService : PointsServiceProtocol) {
        self.pointsService = pointsService
        
        pointsService.pointsSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pointModels in
                guard let self = self else { return }
                
                let newPoints = pointModels.map { PointViewModel(point: $0, pointsService: self.pointsService) }
                Just(newPoints).assign(to: &self.$points)
            })
            .store(in: &cancellables)
    }
    
    func fetch() {
        Task {
            await pointsService.loadPoints(coordinate: searchCoordinate)
        }
    }
}
