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
    
    private let mapService = MapService()
    
    @IBOutlet weak var weatherTable: UITableView!
    
    private let locationManager = CLLocationManager()
    
    private let weatherService = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapService.viewController = self
        mapService.setupMapView(mapView: mapView)
        mapService.addAnnotation(location: getCoordinates(), weatherService: weatherService, mapView: mapView)
        weatherTable.delegate = self
        weatherTable.dataSource = self
        weatherTable.register(UITableViewCell.self, forCellReuseIdentifier: "firstScreenTable")
    }
    
    @IBAction func addButton(_ sender: Any) {
        if let detailsViewController = storyboard?.instantiateViewController(withIdentifier: "goToSearchLocation") as? searchLocationPage {
            detailsViewController.delegate = self
            detailsViewController.modalPresentationStyle = .fullScreen
            present(detailsViewController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "firstScreenTable", for: indexPath)
        let locationItem = locationItems[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        content.text = locationItem.locationName
        content.secondaryText = locationItem.temperature
        
        weatherService.getImage(locationItem.weatherImage) { image in
            DispatchQueue.main.async {
                content.image = image
                cell.contentConfiguration = content
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationItem = locationItems[indexPath.row]
        let region = MKCoordinateRegion(center: locationItem.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        let annotation = MapService.MyAnnotation(coordinate: locationItem.coordinate,
                                                 title: locationItem.locationName,
                                                 subtitle: locationItem.temperature
        )
        
        mapView.delegate = mapService
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getWeatherData(_ data: WeatherResponse) {
        
        let coordinates = CLLocationCoordinate2D(latitude: data.location.lat, longitude: data.location.lon)
        
        let weatherImage = "https:\(data.current.condition.icon)"
        let locationItem = LocationItem(locationName: data.location.name,
                                        temperature: "\(data.current.temp_c)C",
                                        coordinate: coordinates,
                                        weatherImage: weatherImage
        )
        locationItems.append(locationItem)
        weatherTable.reloadData()
        
    }
    
    
    private func addAnnotation(location: CLLocation) {
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
            self.mapView.addAnnotation(customAnnotation)
        }
    }
    
    func getCoordinates() -> CLLocation {
        if let location = locationManager.location {
            return CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            return CLLocation(latitude: 43.0130, longitude: -81.1994)
        }
    }
}

