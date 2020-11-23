//
//  CustomTableViewCell.swift
//  myPlaces
//
//  Created by Андрей Цурка on 10.11.2020.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlase: UIImageView! {
        didSet {
            imageOfPlase.layer.cornerRadius = imageOfPlase.frame.size.height / 2
            imageOfPlase.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var typeLable: UILabel!
    @IBOutlet weak var cosmos: CosmosView! {
        didSet {
            cosmos.settings.updateOnTouch = false
        }
    }
    

}
