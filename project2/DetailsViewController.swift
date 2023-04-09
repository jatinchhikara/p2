//
//  DetailsViewController.swift
//  project2
//
//  Created by Jatin Chhikara on 2023-04-08.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let weatherService = WeatherService()
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var temprature: UILabel!
    
    @IBOutlet weak var condition: UILabel!
    
    @IBOutlet weak var high: UILabel!
    
    @IBOutlet weak var low: UILabel!
    
    @IBOutlet weak var futureList: UITableView!
    
    var points: String?
    
    var futureDays: [ForecastDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeather()
        futureList.delegate = self
        futureList.dataSource = self
        futureList.register(UITableViewCell.self, forCellReuseIdentifier: "list")
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return futureDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)
        let futureDays = futureDays[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "Date: \(futureDays.date)"
        content.secondaryText = "Temperature: \(futureDays.day.avgtemp_c)°C"
        
        weatherService.getImage("https:\(futureDays.day.condition.icon)") { image in
            DispatchQueue.main.async {
                content.image = image
                cell.contentConfiguration = content
            }
        }
        
        return cell
    }
    
    private func loadWeather() {
        weatherService.fetchWeatherData(searchTerm: points) { weatherResponse in
            if let weatherData = weatherResponse {
                
                DispatchQueue.main.async {
                    self.location.text = weatherData.location.name
                    self.temprature.text = "\(weatherData.current.temp_c)°C"
                    self.condition.text = weatherData.current.condition.text
                    if let forecastDay = weatherData.forecast.forecastday.first {
                        self.low.text = "Low: \(forecastDay.day.mintemp_c)°C"
                        self.high.text = "High: \(forecastDay.day.maxtemp_c)°C"
                    }
                    
                    self.futureDays = weatherData.forecast.forecastday
                    self.futureList.reloadData()
                }
                
            } else {
                print("Cannot load weather")
            }
        }
    }
    
}
