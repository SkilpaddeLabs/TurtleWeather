//
//  WeatherData.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/23/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation

class WeatherData {
    
    static let dateFormat = "yyyy-mm-dd' 'HH:mm:ss"
    
    let date:NSDate
    let tempKelvin:Float
    
    class func standardFormat() ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = WeatherData.dateFormat
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter
    }
    
    required init(jsonDict: [String:AnyObject], dateFormatter:NSDateFormatter) {
        
        // Date
        if let dateString = jsonDict[OWMKey.Date] as? String {
            
            
            // TODO: handle nil
            date = dateFormatter.dateFromString(dateString)!
        } else {
            date = NSDate()
        }
        
        // Temperature
        if let main = jsonDict[OWMKey.Main],
           let temp = main[OWMKey.MainTemp] {
            tempKelvin = temp!.floatValue
        } else {
            tempKelvin = 0.0
        }
    }
}
