//
//  UITableViewController.swift
//  myPlaces
//
//  Created by Андрей Цурка on 09.11.2020.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {


    
    var plases: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        plases = realm.objects(Place.self)
    }
    
    
     //MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return plases.isEmpty ? 0 : plases.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = plases[indexPath.row]

        cell.nameLable.text = place.name

        cell.imageOfPlase.layer.cornerRadius = cell.imageOfPlase.frame.size.height / 2
        cell.imageOfPlase.clipsToBounds = true
        cell.locationLable.text = place.location
        cell.typeLable.text = place.type
        cell.imageOfPlase.image = UIImage(data: place.imageData!)
        

        return cell
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindSegue (_ segue: UIStoryboardSegue){
        
        guard let newPlceVC = segue.source as? NewPlaseVC else {return}
        
        newPlceVC.saveNewPlace()

        tableView.reloadData()
    }
    
}
