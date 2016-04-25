//
//  WeatherData.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/23/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation

class WeatherData:CustomStringConvertible {
    
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

    class func standardFormat() ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = OWMKey.DateFormat
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter
    }
    
    class func dataFromJSON(cityName:String, jsonData:NSData) ->[WeatherData]? {
        
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
                as? [String:AnyObject] {
                
                // Create a single formatter to pass in to WeatherData()
                let dateFormatter = WeatherData.standardFormat()
                // Turn JSON dictionary into an array of WeatherData objects
                if let aList = json[OWMKey.List] as? [[String:AnyObject]] {
                    
                    return aList.map{ WeatherData(cityName: cityName,
                                                  jsonDict: $0,
                                             dateFormatter: dateFormatter) }
                }
            }
        } catch {
            print("Error Printing London")
        }
        return [WeatherData]()
    }
    
    required init(cityName:String, jsonDict: [String:AnyObject], dateFormatter:NSDateFormatter) {
        
        // City Name
        self.name = cityName
        // Rain
        if let rainDict = jsonDict[OWMKey.Rain] as? [String:AnyObject],
           let rainVal = rainDict[OWMKey.RainKey] as? Float {
            self.rain = rainVal
        } else {
            self.rain = 0.0
        }
        
        // Date
        if let dateString = jsonDict[OWMKey.Date] as? String {
            // TODO: handle nil
            date = dateFormatter.dateFromString(dateString)!
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
    }
    
    var description: String {
        
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
