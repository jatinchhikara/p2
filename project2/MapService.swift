//
//  MapService.swift
//  project2
//
//  Created by Jatin Chhikara on 2023-04-09.
//

import Foundation
import MapKit

class MapService: NSObject, MKMapViewDelegate {
    private let locationManager = CLLocationManager()
    weak var viewController: UIViewController?


    func setupMapView(mapView: MKMapView) {
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
    
    func addAnnotation(location: CLLocation, weatherService: WeatherService, mapView: MKMapView) {
        let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        weatherService.fetchWeatherData(searchTerm: coordinates) { retrievedWeather in
            guard let weatherData = retrievedWeather else {
                print("Unable to fetch weather information")
                return
            }
            
            guard let dailyForecast = weatherData.forecast.forecastday.first else { return }
            
            let customAnnotation = MapService.MyAnnotation(
                coordinate: location.coordinate,
                title: weatherData.current.condition.text,
                subtitle: "\(weatherData.current.temp_c)C (H:\(dailyForecast.day.maxtemp_c) L:\(dailyForecast.day.mintemp_c))"
            )
            mapView.addAnnotation(customAnnotation)
        }
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        

        let identifier = "Apple rocks!"
        
        guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView else {
            let newView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            newView.canShowCallout = true
            newView.calloutOffset = CGPoint(x: 0, y: 1)
            let button = UIButton(type: .detailDisclosure)
            newView.rightCalloutAccessoryView = button
            return newView
        }
        
        view.annotation = annotation
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        print("calloutAccessoryControlTapped called")

        guard let detailsViewController = viewController?.storyboard?.instantiateViewController(withIdentifier: "goToDetailViewController") as? DetailsViewController else {
            return
        }
        print("22222222222")
        guard let annotation = view.annotation as? MyAnnotation else {
            return
        }
        print("333333333333")
        detailsViewController.points = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
        print("444444444444")
        viewController?.present(detailsViewController, animated: true, completion: nil)
    }
    

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
