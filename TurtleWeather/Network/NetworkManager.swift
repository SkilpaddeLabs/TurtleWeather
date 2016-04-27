//
//  NetworkManager.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/20/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {

    init() {
//        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//        afManager = Alamofire.Manager(configuration: config)
    }
    

    class func getWeather(city:String, completion:WeatherCompletion) {
        
        
        Alamofire.request(OWM_APIRouter.Weather(city))
                 .validate()
                 .response{ (request, response, data, error) in
                
//                // TODO: Check response for error
//                if let urlResponse = response {
//                    //print(urlResponse)
//                    //return
//                }
                // TODO: Do something with errors
                if let anError = error {
                    print(anError)
                    return
                }
                completion(data, error)
        }
    }
    
    class func getForecast(city:String, completion:WeatherCompletion) {
        
        
        Alamofire.request(OWM_APIRouter.Forecast(city))
                 .validate()
                 .response{ (request, response, data, error) in
        
//            // TODO: Check response for error
//            if let urlResponse = response {
//                
//                //print(urlResponse)
//                //return
//            }
            // TODO: Do something with errors
            if let anError = error {
                print(anError)
                return
            }
            completion(data, error)
        }
    }
}