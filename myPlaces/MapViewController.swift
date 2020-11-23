//
//  MapViewController.swift
//  myPlaces
//
//  Created by Андрей Цурка on 23.11.2020.
//

import UIKit

class MapViewController: UIViewController {
    @IBOutlet weak var exit: UIButton!
    
    @IBAction func exitAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
