//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityName {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let weatherDetailModel = WeatherDataModel()

    //TODO: Declare instance variables here
    var locationManager = CLLocationManager()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
//    let lat = param["lat"]!
//    let lon = param["lon"]!
//    let appid = param["appid"]!
//    let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(appid)")
    //Write the getWeatherData method here:
    
    func getWeatherData(param: [String: String]) {

        var url: URL!
        if let lat = param["lat"], let lon = param["lon"], let appid = param["appid"] {
            url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(appid)")!
        } else if let cityName = param["q"], let appid = param["appid"] {
            url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(appid)")
        } else {
            url = URL(string: "http://api.openweathermap.org/data/2.5/weather")
        }
        print("ok")
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as AnyObject
                print(json)
                if let temp = json["main"] as? [String: AnyObject]{
                    let temperature = temp["temp"] as! Double
                    self.weatherDetailModel.temperature = Int(temperature)
                    self.updateUIWithWeatherData()
                }
                if let name = json["name"] as? String {
                    self.weatherDetailModel.city = name
                    
                }
                if let id = json["sys"] as? [String: AnyObject] {
                    let id = id["id"] as! Int
                    self.weatherDetailModel.condition = id
                }
              
            } catch {
                print("error")
            
            }
        }
        task.resume()
        
        
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
//    func updateWeatherData(json: AnyObject) {
//        temperatureLabel.text = String(weatherDetailModel.temperature)
//    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        DispatchQueue.main.async {
            self.weatherIcon.image = UIImage(named: self.weatherDetailModel.updateWeatherIcon(condition: self.weatherDetailModel.condition))
            self.temperatureLabel.text = String(self.weatherDetailModel.temperature - Int(273.15))
            self.cityLabel.text = self.weatherDetailModel.city
        }
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(param: params)
            
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location Unavaliable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func changeName(name: String) {
        let param: [String: String] = ["q": name, "appid": APP_ID]
        getWeatherData(param: param)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            if let destination = segue.destination as? ChangeCityViewController {
                destination.delegate = self
                
            }
        }
    }
    
    
    
    
}


