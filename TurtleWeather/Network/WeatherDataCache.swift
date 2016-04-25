//
//  WeatherDataCache.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/21/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import Alamofire

typealias WeatherCompletion = (NSData?, NSError?)->(Void)
typealias CityWeatherCompletion = ([WeatherData]?, NSError?)->(Void)

// Makes network requests and stores data.
//  Notifies UI that data has been updated.
//  UI objects talk to the cache only, do not
//  make network requests themselves.
class WeatherDataCache {
    
    var weatherData:[WeatherData]?
    // TODO: Serial/Concurrent ???
    let networkQueue = dispatch_queue_create("com.turtlewather.network", DISPATCH_QUEUE_SERIAL)

    init() {
        
    }
    
    //func getCurrentWeather(completion:WeatherCompletion)
    
    func getWeather(cityName:String, completion:CityWeatherCompletion) {
        
        dispatch_async(networkQueue) {
            
            NetworkManager.getWeather(cityName) { (data, error) in
                
                guard let cityData = data else {
                    print("Error getting data from network")
                    return
                }
                guard let decodedData = WeatherData.dataFromJSON(cityName, jsonData: cityData) else {
                    print("Error decoding json data")
                    return
                }
                self.weatherData = decodedData
                self.printWeatherData(decodedData)
                // Update caller
                dispatch_async(dispatch_get_main_queue()) {
                    completion(self.weatherData, error)
                }
            }
        }
    }
    
    func printWeatherData(weatherData:[WeatherData]) {
        
        for data in weatherData {
            print(data.shortDesc)
        }
    }
}