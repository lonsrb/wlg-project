//
//  AppConfig.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation

private var _shared : ApplicationConfiguration!

class ApplicationConfiguration {
    
    static let hostUrl: String = "https://api.marinas.com/v1"
    var pointService : PointsServiceProtocol!
    
    static func configure() {
        _shared = ApplicationConfiguration()
    }
    
    private init() {
        let networkingService = NetworkingService()
        pointService = PointsService(networkingService: networkingService)
    }
    
    class var shared: ApplicationConfiguration {
        if _shared == nil {
            assertionFailure("error: shared must only be called after setup()")
        }
        return _shared
    }
}

struct Endpoints {
    static let pointsSearch : String = "/points/search"
    static let pointRetrieve : String = "/points"
}
