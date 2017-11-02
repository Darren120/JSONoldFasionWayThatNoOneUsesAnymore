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
    
    //Write the getWeatherData method here:
    
    func getWeatherData(param: [String: String]) {
        let lat = param["lat"]!
        let lon = param["lon"]!
        let appid = param["appid"]!
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(appid)")
        print("ok")
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            print("gay")
            if error != nil {
                print("error!")
            } else {
                if let contents = data {
                    do {
                        // do stuff to this
                        let myJSON = try JSONSerialization.jsonObject(with: contents, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            print(myJSON)
                        self.updateWeatherData(json: myJSON)
                        
                    } catch {
                        print(error)
                    }
                }
            }
        }
        task.resume()
        
        
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: AnyObject) {
        if let main = json["main"] as? NSDictionary {
            let temp = main["temp"]
            DispatchQueue.main.async {
                self.temperatureLabel.text = "t\(temp!)"
            }
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        weatherIcon.image = UIImage(named: weatherDetailModel.weatherIconName)
        temperatureLabel.text = String(weatherDetailModel.temperature)
        cityLabel.text = weatherDetailModel.city
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


