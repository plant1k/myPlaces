//
//  UITableViewController.swift
//  myPlaces
//
//  Created by Андрей Цурка on 09.11.2020.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var plases: Results<Place>!
    private var filtredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortedButton: UIBarButtonItem!
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        plases = realm.objects(Place.self)
        
        //Set the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        
    }
    
    
    //MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return plases.isEmpty ? 0 : plases.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    // MARK: Table View delegate
    //
    //    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let place = plases[indexPath.row]
    //
    //        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
    //            StorageManager.deleteObjc(place)
    //            tableView.deleteRows(at: [indexPath], with: .automatic)
    //
    //        }
    //
    //        return UISwipeActionsConfiguration(actions: [deleteAction])
    //    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = plases[indexPath.row]
            StorageManager.deleteObjc(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place = plases[indexPath.row]
            
            let newPlaceVC = segue.destination as! NewPlaseVC
            newPlaceVC.currentPlace = place
            
        }
        
    }
    
    
    @IBAction func unwindSegue (_ segue: UIStoryboardSegue){
        
        guard let newPlceVC = segue.source as? NewPlaseVC else {return}
        
        newPlceVC.savePlace()
        
        tableView.reloadData()
    }
    
    @IBAction func reversedSorted(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting == true {
            reversedSortedButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortedButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    
    @IBAction func sortControl(_ sender: UISegmentedControl) {
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            plases = plases.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            plases = plases.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

extension TableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    private func filterContentForSearchText(_ searchText: String) {
        
        filtredPlaces = plases.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}





