//
//  ViewController.swift
//  project2
//
//  Created by Jatin Chhikara on 2023-04-07.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, SearchDelegate {
    func getWeatherData(_ data: WeatherResponse) {
        print("I am called", data)
    }
    
    
    private let locationManager = CLLocationManager()
    
    private let weatherService = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapSetup()
        addAnnotation(location: getFanshaweLocation())
        // Do any additional setup after loading the view.
    }
    
    
    private func addAnnotation(location: CLLocation) {
        let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        weatherService.fetchWeatherData(searchTerm: coordinates) { retrievedWeather in
            guard let weatherData = retrievedWeather else {
                print("Unable to fetch weather information")
                return
            }
            
            guard let dailyForecast = weatherData.forecast.forecastday.first else { return }
            
            let customAnnotation = MyAnnotation(
                coordinate: location.coordinate,
                title: weatherData.current.condition.text,
                subtitle: "\(weatherData.current.temp_c)C (H:\(dailyForecast.day.maxtemp_c) L:\(dailyForecast.day.mintemp_c))"
            )
            self.mapView.addAnnotation(customAnnotation)
        }
    }
    
    
    private func mapSetup() {
        mapView.delegate = self
        
        guard let location = locationManager.location else {
            return
        }
        
        let radiusInMetres: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMetres, longitudinalMeters: radiusInMetres)
        
        mapView.setRegion(region, animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 1000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Apple rocks!"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 1)
            let button = UIButton(type: .detailDisclosure)
            button.tag = 10000
            view.rightCalloutAccessoryView = button
            view.tintColor = UIColor.black
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    }
    
    func getFanshaweLocation() -> CLLocation {
        guard let location = locationManager.location else {
            return CLLocation(latitude: 43.0130, longitude: -81.1994)
        }
        
        return CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    
    @IBAction func addButton(_ sender: Any) {
        if let detailsViewController = storyboard?.instantiateViewController(withIdentifier: "goToSearchLocation") as? searchLocationPage {
                    detailsViewController.delegate = self
                    detailsViewController.modalPresentationStyle = .fullScreen
                    present(detailsViewController, animated: true, completion: nil)
                }
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

