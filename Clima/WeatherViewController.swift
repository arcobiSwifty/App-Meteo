

import UIKit
import CoreLocation
import Alamofire 
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "af775d651a36217ba4b8ec9d0d74babe"
    

    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModelController()

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation() //background thread
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                let wheaterJSON: JSON = JSON(response.result.value!)
                self.updateWheaterData(json: wheaterJSON)
            } else {
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }

    
    
    //MARK: - JSON
    /***************************************************************/
    
    func updateWheaterData(json: JSON) {
        print(json)
        if let tempResult = json["main"]["temp"].double {//swiftyJSON library //si verifica un errore qua.
            weatherDataModel.temperature = Int(tempResult-273.15)
        
            weatherDataModel.city = json["name"].stringValue
        
            weatherDataModel.condition = json["weather"][0]["id"].intValue
        
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        } else {
            cityLabel.text = json["message"].stringValue
        }
    }

    
    
    
    //MARK: - UI
    /***************************************************************/
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let latitute = String(location.coordinate.latitude)
            let longitute = String(location.coordinate.longitude)
            let params : [String : String] = ["lat": latitute, "long": longitute, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
        cityLabel.text = "Location unavailable"
        
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/

    
    func userEnteredANewCityName(city: String) {
        
        let params: [String: String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationDC = segue.destination as! ChangeCityViewController
            
            destinationDC.delegate = self
            
        }
    }
    
    
    
}


