//
//  FavouriteTVC.swift
//  MyTravelHelper
//
//  Created by Admin on 11/19/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import UIKit

protocol FavouriteTVCDelegate {
    func deSelectFavouriteItem(index: Int?)
}

class FavouriteTVC: UITableViewCell {
    var delegate: FavouriteTVCDelegate?
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var icon: UIButton!
    var index: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureFavouriteTVCUI(index: Int, stationName: String) {
        self.index = index
        self.stationName.text = stationName
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func iconBtnTapped(_ sender: UIButton) {
        self.delegate?.deSelectFavouriteItem(index: index)
    }
}
