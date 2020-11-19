//
//  EndPoint.swift
//  MyTravelHelper
//
//  Created by Prabhat Pandey on 19/11/2020.
//  Copyright © 2020 Prabhat Pandey. All rights reserved.

import Foundation

protocol Endpoint {
    var query: String { get }
    var base: String { get }
    var path: String { get }
}

protocol Querypoint {
    var query: String { get }
}

extension Endpoint {
    
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        components.query = query
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

enum MyTravelFeed {
    case allStations
    case trainFromSource(_ source: String?, _ destination: String?)
    case trainListforDestinationCheck(_ trainID: String?, _ trainDate: String?)
}

extension MyTravelFeed: Endpoint {
    
    var base: String {
        return "http://api.irishrail.ie"
    }
    
    var path: String {
        switch self {
        case .allStations: return "/realtime/realtime.asmx/getAllStationsXML"
        case .trainFromSource : return "/realtime/realtime.asmx/getStationDataByCodeXML"
        case .trainListforDestinationCheck : return "/realtime/realtime.asmx/getTrainMovementsXML"
        }
    }
    
    var query: String {
        switch self {
        case .allStations: return ""
        case .trainFromSource(let source, _): return "StationCode=\(source ?? "")"
        case .trainListforDestinationCheck(let trainID, let trainDate): return "TrainId=\(trainID ?? "")&TrainDate=\(trainDate ?? "")"
        }
    }
}
