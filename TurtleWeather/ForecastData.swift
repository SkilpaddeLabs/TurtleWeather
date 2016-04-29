//
//  ForecastData.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/23/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation

// Structure for holding weather data.
// There are some minor differences between the data returned 
// by the Weather and Forecast APIs
// Weather uses a single struct.
// Forecast uses an array of structs.
struct ForecastData:CustomStringConvertible {
    
    let date:NSDate
    let rain:Float
    let tempKelvin:Float
    let humidity:Float
    let pressure:Float
    let windDirection:Float
    let windSpeed:Float
    let weather:String
    let weatherDescription:String
    let name:String
    // Weather Only
    let sunrise:NSDate?
    let sunset:NSDate?
    
    static func dataFromJSON(cityName:String, jsonData:NSData, isWeather:Bool = false) ->[ForecastData]? {
        
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
                as? [String:AnyObject] {
                
                // Weather API returns a single struct
                // Forecast API returns an array.
                if isWeather {
                    // Turn JSON dictionary into a ForecastData struct.
                    let weatherData = ForecastData(cityName: nil,
                                                   jsonDict: json)
                    return [weatherData]
                    
                } else {
                    // Get City Name - should be same for whole array.
                    let aCity = json[OWMKey.City] as? [String:AnyObject]
                    let aName = aCity?[OWMKey.CityName] as? String ?? "NAME"
                    // Turn JSON dictionary into an array of ForecastData
                    if let aList = json[OWMKey.List] as? Array<[String:AnyObject]> {
                        
                        return aList.map{ ForecastData(cityName: aName,
                                                       jsonDict: $0) }
                    }
                }
            }
        } catch {
            print("Error Printing")
        }
        return [ForecastData]()
    }
    
    init(        date:NSDate,
                 rain:Float,
           tempKelvin:Float,
             humidity:Float,
             pressure:Float,
        windDirection:Float,
            windSpeed:Float,
              weather:String,
   weatherDescription:String,
                 name:String,
              sunrise:NSDate?,
               sunset:NSDate?) {
        
        self.date = date
        self.humidity = humidity
        self.name = name
        self.pressure = pressure
        self.rain = rain
        self.sunrise = sunrise
        self.sunset = sunset
        self.tempKelvin = tempKelvin
        self.weather = weather
        self.weatherDescription = weatherDescription
        self.windDirection = windDirection
        self.windSpeed = windSpeed
    }
    
    init(cityName:String?, jsonDict: [String:AnyObject]) {
        
        // Forecast City Name
        var aName = cityName ?? "NAME"
        // Weather City Name
        if let weatherCityName = jsonDict[OWMKey.CityName] as? String {
            aName = weatherCityName
        }
        self.name = aName
    
        // Rain
        if let rainDict = jsonDict[OWMKey.Rain] as? [String:AnyObject],
           let rainVal = rainDict[OWMKey.RainKey] as? Float {
            self.rain = rainVal
        } else {
            self.rain = 0.0
        }
        
        // Date
        if let dateInt = jsonDict[OWMKey.Timestamp] as? Double {
            date = NSDate.init(timeIntervalSince1970: dateInt)
        } else {
            date = NSDate()
        }
        
        // Weather
        if let weatherArray = jsonDict[OWMKey.Weather] as? [AnyObject],
           let weatherDict = weatherArray.first as? [String:AnyObject],
           let weatherVal = weatherDict[OWMKey.WeatherMain] as? String,
           let weatherDescVal = weatherDict[OWMKey.WeatherDescription] as? String {
            
            self.weather = weatherVal
            self.weatherDescription = weatherDescVal
            
        } else {
            self.weather = ""
            self.weatherDescription = ""
        }
        
        // Wind
        if let rainDict = jsonDict[OWMKey.Wind] as? [String:AnyObject],
           let directionVal = rainDict[OWMKey.WindDirection] as? Float,
           let speedVal = rainDict[OWMKey.WindSpeed] as? Float {
            
            self.windSpeed = speedVal
            self.windDirection = directionVal
        } else {
            self.windSpeed = 0.0
            self.windDirection = 0.0
        }
        
        // *** Main ***
        if let main = jsonDict[OWMKey.Main],
           let tempVal = main[OWMKey.MainTemp] as? Float,
           let humidVal = main[OWMKey.MainHumidity] as? Float,
           let pressureVal = main[OWMKey.MainPressure] as? Float {
            
            self.tempKelvin = tempVal
            self.humidity = humidVal
            self.pressure = pressureVal
            
        } else {
            self.tempKelvin = 0.0
            self.humidity = 0.0
            self.pressure = 0.0
        }
        
        // Sys
        if let sys = jsonDict[OWMKey.Sys] as? [String:AnyObject],
           let sunrise = sys[OWMKey.SysSunrise] as? Double,
           let sunset = sys[OWMKey.SysSunset] as? Double {
            self.sunrise = NSDate(timeIntervalSince1970:sunrise)
            self.sunset = NSDate(timeIntervalSince1970:sunset)
        } else {
            self.sunrise = nil
            self.sunset = nil
        }
    }
    
    var description:String {
        
        var desc = "\(date) \n"
        desc = desc + "Rain: \(rain) \n"
        desc = desc + "Temp: \(tempKelvin) \n"
        desc = desc + "Humid: \(humidity) \n"
        desc = desc + "Press: \(pressure) \n"
        desc = desc + "Wind: \(windDirection) \n"
        desc = desc + "Speed: \(windSpeed) \n"
        desc = desc + "Weather: \(weather) \n"
        desc = desc + "Desc: \(weatherDescription) \n"
        return desc
    }

    var shortDesc:String {
        return "D: \(date) Temp: \(tempKelvin) - \(weather)"
    }
}
