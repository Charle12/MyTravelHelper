//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing
import Alamofire

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    private let client = ApiClient()

    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
            client.fetchallStations(from: .allStations, param: [:]) { result in
                weak var weakSelf = self
                switch result {
                case .success(let result):
                    if let station = result {
                        weakSelf?.self.presenter!.stationListFetched(list: station.stationsList)
                    } else {
                        weakSelf?.presenter!.showNoInterNetAvailabilityMessage()
                    }
                case .failure( _):
                    weakSelf?.presenter!.showNoInterNetAvailabilityMessage()
                }
            }
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        if Reach().isNetworkReachable() {
            client.fetchTrainsFromSource(from: .trainFromSource(sourceCode, destinationCode), param: [:]) { result in
                weak var weakSelf = self
                switch result {
                case .success(let result):
                    if let _trainsList = result?.trainsList {
                        weakSelf?.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                    } else {
                        weakSelf?.presenter!.showNoTrainAvailbilityFromSource()
                    }
                case .failure( _):
                    weakSelf?.presenter!.showNoTrainAvailbilityFromSource()
                }
            }
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            if Reach().isNetworkReachable() {
                client.fetchTrainListforDestinationCheck(from: .trainListforDestinationCheck(trainsList[index].trainCode ?? "", dateString), param: [:]) { result in
                    weak var weakSelf = self
                    switch result {
                    case .success(let result):
                        if let _movements = result?.trainMovements {
                            let sourceIndex = _movements.firstIndex(where: {$0.locationCode?.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                            let destinationIndex = _movements.firstIndex(where: {$0.locationCode!.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                            let desiredStationMoment = _movements.filter{$0.locationCode!.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                            let isDestinationAvailable = desiredStationMoment.count == 1

                            if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                                _trainsList[index].destinationDetails = desiredStationMoment.first
                            }
                        }
                        group.leave()
                    case .failure( _):
                        weakSelf?.presenter!.showNoTrainAvailbilityFromSource()
                    }
                }
            } else {
                self.presenter!.showNoInterNetAvailabilityMessage()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
