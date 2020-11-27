//
//  MapViewController.swift
//  myPlaces
//
//  Created by Андрей Цурка on 23.11.2020.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address:String?)
}

class MapViewController: UIViewController {
    
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    
    
    var previosLocation: CLLocation? {
        didSet {
            mapManager.startTrakingUserLocations(
                for: mapView,
                and: previosLocation) { (currentLocation) in
                
                self.previosLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
                
            }
            
        }
    }
    
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var exit: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var location: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var destination: UILabel!
    
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(address.text)
        dismiss(animated: true)
        
    }
    
    @IBAction func centerLocation(_ sender: Any) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func exitAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonPressed() {
        destination.isHidden = false
        mapManager.getDirections(for: mapView) { (location) in
            self.previosLocation = location
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        address.text = ""
        mapView.delegate = self
        
        setupMapView()
        mapManager.checkLoctionServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        destination.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            location.isHidden = true
            address.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            
            annotationView?.rightCalloutAccessoryView = imageView
        }

        return annotationView
    }
    
    // Центр отображаемой области
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previosLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print("\(error)")
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                    self.address.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.address.text = "\(streetName!)"
                } else {
                    self.address.text = ""
                }
                
            }
        }
    }
    
    // Рисуем маршрут
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.locationManagerDidChangeAuthorization(manager: mapManager.locationManager, mapView: mapView, segueIndentifier: incomeSegueIdentifier)
    }
}



