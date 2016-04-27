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
typealias CityForecastCompletion = (Array<[ForecastData]>?, NSError?)->(Void)
typealias CityDayForecastCompletion = ([ForecastData]?, NSError?)->(Void)

// Makes network requests and stores data.
//  Notifies UI that data has been updated.
//  UI objects talk to the cache only, do not
//  make network requests themselves.
class WeatherDataCache {
    
    let timeoutInterval = 15.0 * 60.0
    var lastUpdate:NSDate?
    var weatherData:[ForecastData]?
    // TODO: Serial/Concurrent ???
    let networkQueue = dispatch_queue_create("com.turtleweather.network", DISPATCH_QUEUE_SERIAL)

    init() {
        
    }
    
    func getForecast(cityName:String, forDate searchDate:NSDate, completion:CityDayForecastCompletion) {
        
        // Check if we have cached data.
        if let data = weatherData,
           lastDate = lastUpdate
            where lastDate.timeIntervalSinceNow < timeoutInterval {
            
            let calendar = calendarForWeatherDate(data.first!.date)
            let dayData = self.weatherData?.filter {
                calendar.isDate($0.date, inSameDayAsDate: searchDate)
            }
            
            // Update caller
            dispatch_async(dispatch_get_main_queue()) {
                completion(dayData, nil)
            }
            return
        }
    }
    
    func getForecast(cityName:String, completion:CityForecastCompletion) {
        
        // Check if we have cached data.
        if let data = weatherData,
           lastDate = lastUpdate
           where lastDate.timeIntervalSinceNow < timeoutInterval {
           
            let splitData = self.splitDataByDays(data)
            // Update caller
            dispatch_async(dispatch_get_main_queue()) {
                completion(splitData, nil)
            }
            return
        }
        // Make network request.
        dispatch_async(networkQueue) {
            
            NetworkManager.getForecast(cityName) { (data, error) in
                
                guard let cityData = data else {
                    print("Error getting data from network")
                    return
                }
                guard let decodedData = ForecastData.dataFromJSON(cityName, jsonData: cityData) else {
                    print("Error decoding json data")
                    return
                }
                // Set last update time.
                self.lastUpdate = NSDate()
                print(self.lastUpdate)
                print(decodedData)
                self.weatherData = decodedData
                //self.printWeatherData(decodedData)
                let splitData = self.splitDataByDays(decodedData)
                // Update caller
                dispatch_async(dispatch_get_main_queue()) {
                    completion(splitData, error)
                }
            }
        }
    }
    
    func calendarForWeatherDate(activeDate:NSDate) ->NSCalendar {
        
        let gmt = NSTimeZone(forSecondsFromGMT: 0)
        let dataTimeZoneOffset = gmt.secondsFromGMTForDate(activeDate)
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: dataTimeZoneOffset)
        return calendar
    }
    
    func splitDataByDays(weatherData:[ForecastData]) ->Array<[ForecastData]>{
        
        // Create calendar object with correct time zone.
        var activeDate = weatherData.first!.date
        //let calendar = calendarForWeatherDate(activeDate)
        let calendar = NSCalendar.currentCalendar()
        
        // Split data into arrays based on date.
        var days = Array<[ForecastData]>()
        var currentDay = [ForecastData]()
        
        for data in weatherData {
            
            let sameDate = calendar.isDate(data.date, inSameDayAsDate: activeDate)
    
            if !sameDate {
                days.append(currentDay)
                currentDay = [ForecastData]()
                activeDate = calendar.startOfDayForDate(data.date)
            }
            currentDay.append(data)
        }
        days.append(currentDay)
        return days
    }
    
    func printWeatherData(weatherData:[ForecastData]) {
        
        for data in weatherData {
            print(data.shortDesc)
        }
    }
}