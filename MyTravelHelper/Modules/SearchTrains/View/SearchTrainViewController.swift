//
//  SearchTrainViewController.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown

class SearchTrainViewController: UIViewController {
    private let reuseIdentifier = "FavouriteTVC"
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var sourceTxtField: UITextField!
    @IBOutlet weak var trainsListTable: UITableView!
    
    @IBOutlet weak var destinationFavBtn: UIButton!
    @IBOutlet weak var sourceFavBtn: UIButton!

    var stationsList:[Station] = [Station]()
    var trains:[StationTrain] = [StationTrain]()
    var presenter:ViewToPresenterProtocol?
    var dropDown = DropDown()
    var searchTapped: Bool = false
    var favouriteStationsList:[String] = [String]()
    var transitPoints:(source:String,destination:String) = ("","")

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecords()
        self.trainsListTable.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        searchTapped = false
    }

    override func viewWillAppear(_ animated: Bool) {
        if stationsList.count == 0 {
            SwiftSpinner.useContainerView(view)
            SwiftSpinner.show("Please wait loading station list ....")
            presenter?.fetchallStations()
        }
    }

    @IBAction func searchTrainsTapped(_ sender: Any) {
        view.endEditing(true)
        searchTapped = true
        showProgressIndicator(view: self.view)
        presenter?.searchTapped(source: transitPoints.source, destination: transitPoints.destination)
    }
    
    @IBAction func destinationFavBtnTapped(sender: UIButton) {
        if ((destinationTextField.text ?? "").count > 0) {
            if (destinationFavBtn.isSelected) {
                self.removeData(stationName: destinationTextField.text ?? "")
            } else {
                self.saveData(stationName: destinationTextField.text ?? "")
            }
            destinationFavBtn.isSelected = !destinationFavBtn.isSelected
            fetchRecords()
        }
    }
    
    @IBAction func sourceFavBtnTapped(sender: UIButton) {
        if ((sourceTxtField.text ?? "").count > 0) {
            if (sourceFavBtn.isSelected) {
                self.removeData(stationName: sourceTxtField.text ?? "")
            } else {
                self.saveData(stationName: sourceTxtField.text ?? "")
            }
            sourceFavBtn.isSelected = !sourceFavBtn.isSelected
            fetchRecords()
        }
    }
    
    fileprivate func saveData(stationName: String) {
        CoreDataManager.sharedManager.saveStationNameInEntity(stationName: stationName) { (flag, error, result) in
            showAlert(title: "", message: error, actionTitle: "Okay")
        }
    }
    
    fileprivate func removeData(stationName: String) {
        CoreDataManager.sharedManager.removeStationNameInEntity(stationName: stationName) { (flag, error, result) in
            showAlert(title: "", message: error, actionTitle: "Okay")
        }
    }
    
    fileprivate func fetchRecords() {
        CoreDataManager.sharedManager.fetchAllSavedInformationFromDB { (success, error, result) in
            favouriteStationsList = result
            trainsListTable.isHidden = (result.count > 0) ? false : true
            trainsListTable.reloadData()
        }
    }
    
    func showAlert(name: String) {
        let alertController = UIAlertController(title: name, message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Copy station name to source.", style: .default) { [self] (action:UIAlertAction) in
            self.sourceTxtField.text = name
            sourceFavBtn.isSelected = true
        }

        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed cancel");
        }

        let action3 = UIAlertAction(title: "Copy station name to destination.", style: .default) { [self] (action:UIAlertAction) in
            self.destinationTextField.text = name
            destinationFavBtn.isSelected = true
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension SearchTrainViewController:PresenterToViewProtocol {
    func showNoInterNetAvailabilityMessage() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Internet", message: "Please Check you internet connection and try again", actionTitle: "Okay")
    }

    func showNoTrainAvailbilityFromSource() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Trains", message: "Sorry No trains arriving source station in another 90 mins", actionTitle: "Okay")
    }

    func updateLatestTrainList(trainsList: [StationTrain]) {
        hideProgressIndicator(view: self.view)
        trains = trainsList
        trainsListTable.isHidden = false
        trainsListTable.reloadData()
    }

    func showNoTrainsFoundAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        trainsListTable.isHidden = true
        showAlert(title: "No Trains", message: "Sorry No trains Found from source to destination in another 90 mins", actionTitle: "Okay")
    }

    func showAlert(title:String,message:String,actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        searchTapped = false
        trainsListTable.isHidden = false
        trainsListTable.reloadData()
    }

    func showInvalidSourceOrDestinationAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "Invalid Source/Destination", message: "Invalid Source or Destination Station names Please Check", actionTitle: "Okay")
    }

    func saveFetchedStations(stations: [Station]?) {
        if let _stations = stations {
          self.stationsList = _stations
        }
        SwiftSpinner.hide()
    }
}

extension SearchTrainViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown = DropDown()
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = stationsList.map {$0.stationDesc ?? ""}
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            if textField == self.sourceTxtField {
                self.transitPoints.source = item
                if (favouriteStationsList.contains(item)) {
                    sourceFavBtn.isSelected = true
                }
            } else {
                self.transitPoints.destination = item
                if (favouriteStationsList.contains(item)) {
                    destinationFavBtn.isSelected = true
                }
            }
            textField.text = item
        }
        dropDown.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dropDown.hide()
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputedText = textField.text {
            var desiredSearchText = inputedText
            if string != "\n" && !string.isEmpty{
                desiredSearchText = desiredSearchText + string
            }else {
                desiredSearchText = String(desiredSearchText.dropLast())
            }
            dropDown.dataSource = stationsList.map {$0.stationDesc ?? ""}
            dropDown.show()
            dropDown.reloadAllComponents()
        }
        return true
    }
}

extension SearchTrainViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchTapped == false) ? favouriteStationsList.count : trains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (searchTapped == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "train", for: indexPath) as! TrainInfoCell
            let train = trains[indexPath.row]
            cell.configureTrainInfoCellUI(train: train)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FavouriteTVC
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configureFavouriteTVCUI(index: indexPath.row, stationName: favouriteStationsList[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (searchTapped == false) ? 52 : 140.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(name: favouriteStationsList[indexPath.row])
    }
}

extension SearchTrainViewController : FavouriteTVCDelegate {
    func deSelectFavouriteItem(index: Int?) {
        CoreDataManager.sharedManager.removeStationNameInEntity(stationName: favouriteStationsList[index ?? 0]) { (flag, error, result) in
            if (flag) {
                favouriteStationsList.remove(at: index ?? 0)
                trainsListTable.reloadData()
            } else {
                showAlert(title: "", message: error, actionTitle: "Okay")
            }
        }
    }
}
