//
//  MapViewController.swift
//  NOON
//
//  Created by mohammad mokhtarzade on 7/4/19.
//  Copyright © 2019 Satya. All rights reserved.
//

import UIKit
import GoogleMaps
class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMarker()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    private func setMarker() {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: 35.7643, longitude: 51.4183)
        
        marker.title = "Hello"
        marker.map = mapView
        
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let latitude = self.locationManager.location?.coordinate.latitude
        let longitude = self.locationManager.location?.coordinate.longitude

        let camera = GMSCameraPosition.camera(withLatitude: latitude ?? 35.4545, longitude: longitude ?? 35.554, zoom: 15)
        
        mapView.animate(to: camera)
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    }
}
