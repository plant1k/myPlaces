//
//  mapManager.swift
//  myPlaces
//
//  Created by Андрей Цурка on 26.11.2020.
//

import UIKit
import MapKit

class MapManager {
    
    
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionMeters = 1000.00
    private var directionsArray: [MKDirections] = [ ]
    
    
    func setupLocationManager() {
        //locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    // Маркер заведения
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    // Проверка доступности сервисов геолокации
    func checkLoctionServices(mapView: MKMapView, segueIdentifier: String) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManagerDidChangeAuthorization(manager: locationManager, mapView: mapView, segueIndentifier: segueIdentifier)
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            // clouser()
            
        } else {
            self.showAlert(title: "Location disabled", message: "Turn on")
        }
        
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow =  UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
    
    
    
    // Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previosLocation: (CLLocation) -> ()) {
        
        guard  let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Erorr")
            return
        }
        
        locationManager.startUpdatingLocation()
        previosLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Not fount")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                print("Расстояние до места \(distance) км., время до места \(timeInterval) мин. ")
                
                
                
                
            }
        }
        
    }
    
    // Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Фокус карты на местоположение пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
        } else {
            print("Error")
        }
    }
    // Настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrakingUserLocations(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else {return}
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
        
    }
    
    
    
    
    // Сброс всех ранее построенных маршрутов перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView:MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    func locationManagerDidChangeAuthorization( manager: CLLocationManager, mapView: MKMapView, segueIndentifier: String) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIndentifier == "getAddress" { self.showUserLocation(mapView: mapView) }
            break
        case .denied:
            self.showAlert(title: "Error", message: "Error")
            break
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case")
        }
    }
    
    
}


