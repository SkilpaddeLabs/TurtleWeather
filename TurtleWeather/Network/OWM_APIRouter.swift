//
//  OWM_APIRouter.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/22/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import Alamofire

// Organizes API calls for Open Weather Map
enum OWM_APIRouter:URLRequestConvertible {
    
    // Example URL Format "http://api.openweathermap.org/data/2.5/forecast?q=London&APPID=XXXXXXXX"
    static let baseUrlString = "http://api.openweathermap.org"
    static let forcastPath = "/data/2.5/forecast"
    static let APPID = "get your own id"
    
    case City(String) // http://api.openweathermap.org/data/2.5/forecast?q=London,us
    
    // Returns HTTP method for each API endpoint.
    var method:Alamofire.Method {
        switch self {
        case .City:
            return .GET
        }
    }
    
    var relativePath:String? {
        // Find relative path for API endpoint.
        let relative:String?
        switch self {
        case .City:
            relative = OWM_APIRouter.forcastPath
        }
        return relative
    }
    
    var parameters:[String:AnyObject]? {
        switch self {
        case .City(let city):
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
