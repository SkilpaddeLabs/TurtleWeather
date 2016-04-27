//
//  OWM_APIRouter.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/22/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import Alamofire

// JSON data structure keys.
struct OWMKey {
    
    static let City = "city"
    static let CityName = "name"
    
    static let List = "list"
    
    static let Rain = "rain" // Not in weather.
    static let RainKey = "3h"
    static let Date = "dt_txt"
    static let DateFormat = "yyyy-mm-dd' 'HH:mm:ss"
    
    static let Weather = "weather"
    static let WeatherDescription = "description"
    static let WeatherMain = "main"
    
    static let Wind = "wind"
    static let WindDirection = "deg"
    static let WindSpeed = "speed"
    
    static let Main = "main"
    static let MainTemp = "temp" // Only in weather?
    static let MainHumidity = "humidity"
    static let MainPressure = "pressure"
    static let MainCity = "name"
    
    static let Sys = "sys"
    static let SysSunrise = "sunrise"
    static let SysSunset = "sunset"
}

// Organizes API calls for Open Weather Map
enum OWM_APIRouter:URLRequestConvertible {
    
    // Example URL Format "http://api.openweathermap.org/data/2.5/forecast?q=London&APPID=XXXXXXXX"
    static let baseUrlString = "http://api.openweathermap.org"
    static let APPID = "get your own id"
    
    case Weather(String) // http://api.openweathermap.org/data/2.5/weather?q=London
    case Forecast(String) // http://api.openweathermap.org/data/2.5/forecast?q=London,us
    
    // Returns HTTP method for each API endpoint.
    var method:Alamofire.Method {
        switch self {
        case .Weather:
            return .GET
        case .Forecast:
            return .GET
        }
    }
    
    var relativePath:String? {
        // Find relative path for API endpoint.
        let relative:String?
        switch self {
        case .Weather:
            relative = "/data/2.5/weather"
        case .Forecast:
            relative = "/data/2.5/forecast"
        }
        return relative
    }
    
    var parameters:[String:AnyObject]? {
        switch self {
        case .Weather(let city):
            return ["q":city, "APPID":OWM_APIRouter.APPID]
        case .Forecast(let city):
            return ["q":city, "APPID":OWM_APIRouter.APPID]
        }
    }
    
    var url:NSURL {
        
        // Append relative path to base URL.
        var newURL = OWM_APIRouter.baseUrlString
        if let relativePath = self.relativePath {
            newURL = newURL.stringByAppendingString(relativePath)
        }
        return NSURL(string: newURL)!
    }
    
    // URLRequestConvertible method.
    var URLRequest: NSMutableURLRequest {
        
        let encoding = Alamofire.ParameterEncoding.URL
        let request = NSMutableURLRequest(URL: self.url)
        let (encodedRequest, _) = encoding.encode( request, parameters: self.parameters)
        encodedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        encodedRequest.HTTPMethod = self.method.rawValue
        return encodedRequest
    }
}
