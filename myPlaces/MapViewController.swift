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
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionMeters = 1000.00
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = [ ]
    var previosLocation: CLLocation? {
        didSet{
            startTrakingUserLocations()
        }
    }
    
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var exit: UIButton!
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var location: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var destination: UILabel!
    

    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(address.text)
        dismiss(animated: true)
        
    }
    
    @IBAction func centerLocation(_ sender: Any) {
        showUserLocation()
    }
    
    @IBAction func exitAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonPressed() {
        destination.isHidden = false
        getDirections()
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        address.text = ""
        mapKit.delegate = self
        
        
        setupMapView()
        checkLoctionServices()
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        destination.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            location.isHidden = true
            address.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
           
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        
        mapKit.removeOverlays(mapKit.overlays)
        directionsArray.append(directions)
        
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
        
    }
    
    private func setupPlaceMark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapKit.showAnnotations([annotation], animated: true)
            self.mapKit.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    private func checkLoctionServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            print("OK")
            setupLocationManager()
             
        } else {
            self.showAlert(title: "Location disabled", message: "Turn on")
        }
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapKit.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied:
            showAlert(title: "Eroor", message: "Error")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case")
        }
    }
    
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
 
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func getDirections() {
        
      
        
        guard  let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Erorr")
            return
        }
        
        locationManager.startUpdatingLocation()
        previosLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Not fount")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { (response, error) in
            if let error = error {
                print("\(error)")
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Not found")
                return
            }
            for route in response.routes {
                self.mapKit.addOverlay(route.polyline)
                self.mapKit.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                print("Расстояние до места \(distance) км., время до места \(timeInterval) мин. ")
                
                self.destination.text = " Расстояние до места \(distance) км., время до места \(timeInterval) мин."
               
            }
        }
        
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
        
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showUserLocation() {

        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapKit.setRegion(region, animated: true)
        }
    }
    
    private func startTrakingUserLocations() {
       
        guard let previosLocation = previosLocation else {return}
        let center = getCenterLocation(for: mapKit)
        
        guard center.distance(from: previosLocation) > 50 else { return }
            
        self.previosLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapKit.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previosLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
}
