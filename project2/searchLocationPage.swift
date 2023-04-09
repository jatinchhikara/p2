//
//  searchLocationPage.swift
//  project2
//
//  Created by Jatin Chhikara on 2023-04-08.
//

import UIKit

class searchLocationPage: UIViewController, UITextFieldDelegate {
    
    private let weatherService = WeatherService()
    
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    
    @IBOutlet weak var weatherImg: UIImageView!
    
    
    @IBOutlet weak var tempratureLabel: UILabel!
    
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    
    @IBOutlet weak var conditionText: UILabel!
    weak var delegate: SearchDelegate?
    
    var dataToSend: WeatherResponse?
    let firstScreen = "firstScreen"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySampleImageForDemo()
        locationTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func displaySampleImageForDemo() {
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .systemTeal, .systemYellow])
        weatherImg.preferredSymbolConfiguration = config
        weatherImg.image = UIImage(systemName: "bolt.circle")
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func addLocationBtn(_ sender: Any) {
        if let dataToSend = self.dataToSend {
            delegate?.getWeatherData(dataToSend)
        }
        dismiss(animated: true)
    }
    
    @IBAction func searchIcon(_ sender: UIButton) {
        weatherService.fetchWeatherData(searchTerm: locationTextField.text) { retrievedWeather in
            guard let weatherResponse = retrievedWeather else {
                print("Unable to fetch weather information")
                return
            }
            
            self.dataToSend = weatherResponse
            
            DispatchQueue.main.async {
                self.locationNameLabel.text = weatherResponse.location.name
                self.tempratureLabel.text = "\(weatherResponse.current.temp_c)C"
                self.conditionText.text = weatherResponse.current.condition.text
            }
        }
    }
    
}

protocol SearchDelegate: AnyObject {
    func getWeatherData(_ data: WeatherResponse)
}
