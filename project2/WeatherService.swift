//
//  WeatherService.swift
//  project2
//
//  Created by Jatin Chhikara on 2023-04-08.
//

import Foundation
import MapKit

class WeatherService {
    private func createUrl(query: String) -> URL? {
        guard let url = "https://api.weatherapi.com/v1/forecast.json?key=0fa41dd0fa424f0da03235656230904&q=\(query)&days=7&aqi=no&alerts=no"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: url)
    }
    
    func fetchWeatherData(searchTerm: String?, completion: @escaping (WeatherResponse?) -> Void) {
        guard let searchTerm = searchTerm else {
            completion(nil)
            return
        }
        
        guard let url = createUrl(query: searchTerm) else {
            print("Unable to generate url")
            completion(nil)
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { responseData, httpResponse, error in
            print("API call finished")
            
            guard let responseData = responseData else {
                print("Data not found")
                completion(nil)
                return
            }
            
            if let weatherData = self.decodeJson(data: responseData) {
                completion(weatherData)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func getImage(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
    }
    
    private func decodeJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error decoding: \(error)")
        }
        return weather
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
    let forecast: Forecast
}

struct Location: Decodable {
    let name: String
    let lat: Double
    let lon: Double
}

struct Weather: Decodable {
    let temp_c: Float
    let condition: Conditions
}

struct Conditions: Decodable {
    let text: String
    let icon: String
}

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: Day
}

struct Day: Decodable {
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c: Float
    let condition: Conditions
}

struct LocationItem {
    var locationName: String
    var temperature: String
    var coordinate: CLLocationCoordinate2D
    var weatherImage: String
}

