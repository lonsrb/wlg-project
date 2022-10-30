//
//  Networking.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/29/22.
//

import Foundation

enum NetworkingError: Error {
    case invalidUrl(String)
    case badResponse
}

protocol NetworkingServiceProtocol {
    func performUrlRequest(_ request : URLRequest) async throws -> (Data, URLResponse)
}

class NetworkingService : NetworkingServiceProtocol {
    //this seems like a straightforward passthrough, except this is the only
    //file in the project that uses URLSession which allows us to swap our
    //URLSession responses with a mocked implementaions
    func performUrlRequest(_ request: URLRequest) async throws ->  (Data, URLResponse) {
        return try await URLSession.shared.data(for: request)
    }
}
