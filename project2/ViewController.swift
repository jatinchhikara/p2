//
//  ViewController.swift
//  project2
//
//  Created by Jatin Chhikara on 2023-04-07.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapSetup()
        addAnnotation(location: getFanshaweLocation())
        // Do any additional setup after loading the view.
    }
    
    private func addAnnotation(location: CLLocation) {
        
        let annotation = MyAnnotation(coordinate: location.coordinate, title: "Fanshawe", subtitle: "London ON",  glyphText: "P")
        
        mapView.addAnnotation(annotation)
    }
    
    private func mapSetup() {
        mapView.delegate = self
        
        guard let location = locationManager.location else {
            return
        }
        
        let radiusInMetres: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMetres, longitudinalMeters: radiusInMetres)
        
        mapView.setRegion(region, animated: true)
        
        let cameraBoundry = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundry, animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 1000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    func getFanshaweLocation() -> CLLocation {
        return CLLocation(latitude: 43.0130, longitude: -81.1994)
    }
    
    
    @IBAction func addButton(_ sender: Any) {
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    class MyAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        var glyphText: String?
        init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
            self.glyphText = glyphText
            
            super.init()
        }
    }
}

