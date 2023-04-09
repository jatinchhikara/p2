//
//  ViewController.swift
//  project2
//
//  Created by Jatin Chhikara on 2023-04-07.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, SearchDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locationItems: [LocationItem] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "firstScreenTable", for: indexPath)
        let locationItem = locationItems[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        content.text = locationItem.locationName
        content.secondaryText = locationItem.temperature
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let locationItem = locationItems[indexPath.row]
            let region = MKCoordinateRegion(center: locationItem.coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            
            let annotation = MyAnnotation(coordinate: locationItem.coordinate,
                                          title: locationItem.locationName,
                                          subtitle: locationItem.temperature
            )
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    func getWeatherData(_ data: WeatherResponse) {
        if let forecastDay = data.forecast.forecastday.first {
            let locationItem = LocationItem(locationName: data.location.name,
                                            temperature: "\(data.current.temp_c)C (H:\(forecastDay.day.maxtemp_c) L:\(forecastDay.day.mintemp_c))",
                                            coordinate: CLLocationCoordinate2D(latitude: data.location.lat, longitude: data.location.lon)
            )
            locationItems.append(locationItem)
            weatherTable.reloadData()
        }
    }
    
    
    @IBOutlet weak var weatherTable: UITableView!
    private let locationManager = CLLocationManager()
    
    private let weatherService = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapSetup()
        addAnnotation(location: getCoordinates())
        
        weatherTable.delegate = self
        weatherTable.dataSource = self
        weatherTable.register(UITableViewCell.self, forCellReuseIdentifier: "firstScreenTable")
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
        guard let detailsViewController = storyboard?.instantiateViewController(withIdentifier: "goToDetailViewController") as? DetailsViewController else {
            return
        }
        
        guard let annotation = view.annotation as? MyAnnotation else {
            return
        }
        
        detailsViewController.points = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
        
        present(detailsViewController, animated: true, completion: nil)
    }

    
    func getCoordinates() -> CLLocation {
        if let location = locationManager.location {
            return CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            return CLLocation(latitude: 43.0130, longitude: -81.1994)
        }
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

