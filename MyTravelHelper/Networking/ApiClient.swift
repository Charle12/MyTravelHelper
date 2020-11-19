//
//  ApiClient.swift
//  MyTravelHelper
//
//  Created by Prabhat Pandey on 19/11/2020.
//  Copyright © 2020 Prabhat Pandey. All rights reserved.

import UIKit

class ApiClient: GenericAPIClient {
    let session: URLSession
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func fetchallStations(from feedType: MyTravelFeed, param: Parameters, completion: @escaping (Result<Stations?, APIError>) -> Void) {
        let endpoint = feedType
        let request = endpoint.request
        fetch(with: request, decode: { json -> Stations? in
            guard let baseModel = json as? Stations else { return  nil }
            return baseModel
        }, completion: completion)
    }

    func fetchTrainsFromSource(from feedType: MyTravelFeed, param: Parameters, completion: @escaping (Result<StationData?, APIError>) -> Void) {
        let endpoint = feedType
        let request = endpoint.request
        fetch(with: request, decode: { json -> StationData? in
            guard let baseModel = json as? StationData else { return  nil }
            return baseModel
        }, completion: completion)
    }
    
    func fetchTrainListforDestinationCheck(from feedType: MyTravelFeed, param: Parameters, completion: @escaping (Result<TrainMovementsData?, APIError>) -> Void) {
        let endpoint = feedType
        let request = endpoint.request
        fetch(with: request, decode: { json -> TrainMovementsData? in
            guard let baseModel = json as? TrainMovementsData else { return  nil }
            return baseModel
        }, completion: completion)
    }
}
