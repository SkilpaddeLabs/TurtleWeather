//
//  NetworkManager.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/20/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import Alamofire

typealias WeatherAPICompletion = Result<NSData, NSError> ->Void

class NetworkManager {

    init() {
    }
    
    class func getWeather(city:String, completion:WeatherAPICompletion) {
        
        
        Alamofire.request(OWM_APIRouter.Weather(city))
                 .validate()
                 .response{ (request, response, data, error) in
                
            // Check Response
            if let urlResponse = response,
               let responseError = NetworkManager.checkURLResponse(urlResponse) {
                completion(.Failure(responseError))
                return
            }
            // Check Error
            guard error == nil else  {
                completion(.Failure(error!))
                return
            }
            // Check for data.
            guard let someData = data else {
                let missingData = NetworkManager.missingDataError()
                completion(.Failure(missingData))
                return
            }
            // Return Success
            completion(.Success(someData))
        }
    }
    
    class func getForecast(city:String, completion:WeatherAPICompletion) {
        
        
        Alamofire.request(OWM_APIRouter.Forecast(city))
                 .validate()
                 .response{ (request, response, data, error) in
        
            // Check Response
            if let urlResponse = response,
                let responseError = NetworkManager.checkURLResponse(urlResponse) {
                completion(.Failure(responseError))
                return
            }
            // Check Error
            guard error == nil else  {
                completion(.Failure(error!))
                return
            }
            // Check for data.
            guard let someData = data else {
                let missingData = NetworkManager.missingDataError()
                completion(.Failure(missingData))
                return
            }
            // Return Success
            completion(.Success(someData))
        }
    }
    
    class func find(searchString:String, completion:WeatherAPICompletion) {
        
        Alamofire.request(OWM_APIRouter.Find(searchString))
                 .validate()
                 .response{ (request, response, data, error) in
           
            // Check Response
            if let urlResponse = response,
                let responseError = NetworkManager.checkURLResponse(urlResponse) {
                completion(.Failure(responseError))
                return
            }
            // Check Error
            guard error == nil else {
                completion(.Failure(error!))
                return
            }
            // Check for data.
            guard let someData = data else {
                let missingData = NetworkManager.missingDataError()
                completion(.Failure(missingData))
                return
            }
            // Return Success
            completion(.Success(someData))
        }
    }
    
    class func missingDataError() ->NSError {
        
        let infoDict = [NSLocalizedDescriptionKey: "Data not found.",
               NSLocalizedRecoveryOptionsErrorKey: "No valid data was returned for this request."]
        return NSError(domain: "com.turtleweather", code: -50, userInfo: infoDict)
    }
    
    class func checkURLResponse(urlResponse:NSHTTPURLResponse) ->NSError?{
        
        var error:NSError? = nil
        if (urlResponse.statusCode == 401) {
            
            let infoDict = [NSLocalizedDescriptionKey: "API KEY Error",
                   NSLocalizedRecoveryOptionsErrorKey: "Valid API Key is missing. Register for a free key at https://home.openweathermap.org/users/sign_up"]
            
            error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorUserAuthenticationRequired,
                            userInfo: infoDict)
        }
        
        if (urlResponse.statusCode == 404) {
            
            let infoDict = [NSLocalizedDescriptionKey: "Resource not found.",
                   NSLocalizedRecoveryOptionsErrorKey: "Resource not found."]
            
            error = NSError(domain: NSURLErrorDomain,
                            code: NSURLErrorUserAuthenticationRequired,
                            userInfo: infoDict)
        }
        return error
    }
}