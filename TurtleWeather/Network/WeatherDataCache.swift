//
//  WeatherDataCache.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/21/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation

typealias FullForecastCompletion = (Array<[ForecastData]>?, NSError?)->(Void)
typealias DayForecastCompletion = ([ForecastData]?, NSError?)->(Void)
typealias WeatherCompletion = (ForecastData?, NSError?)->(Void)

// Makes network requests and stores data.
//  Notifies UI that data has been updated.
//  UI objects talk to the cache only, do not
//  make network requests themselves.
class WeatherDataCache {
    
    let timeoutInterval = 15.0 * 60.0
    var lastWeatherUpdate:NSDate?
    var lastForecastUpdate:NSDate?
    var weatherData:ForecastData?
    var forecastData:[ForecastData]?
    // TODO: Serial/Concurrent ???
    let networkQueue = dispatch_queue_create("com.turtleweather.network", DISPATCH_QUEUE_SERIAL)

    init() {
        
    }
    
    func getWeather(cityName:String, completion:WeatherCompletion) {
    
        // Check if we have recently cached data.
        if let data = self.weatherData,
           lastDate = self.lastWeatherUpdate
            where lastDate.timeIntervalSinceNow < timeoutInterval {
            
            // Update caller
            dispatch_async(dispatch_get_main_queue()) {
                completion(data, nil)
            }
            return
        } else {
            // Make Network Request
            NetworkManager.getWeather(cityName) { (data, error) in
                self.decodeWeatherData(data, error: error, completion: completion)
            }
        }
    }
    
    func decodeWeatherData(data:NSData?, error:NSError?, completion:WeatherCompletion) {
        
        guard let weatherData = data else {
            print("Error getting weather data from network")
            return
        }
        guard let decodedData = ForecastData.dataFromJSON( "NAME",
                                                 jsonData: weatherData,
                                                isWeather: true) else {
            print("Error decoding json data")
            return
        }
        // Set last update time.
        self.lastWeatherUpdate = NSDate()
        self.weatherData = decodedData.first
        // Update caller
        dispatch_async(dispatch_get_main_queue()) {
            completion(self.weatherData, error)
        }
    }
    
    func getForecast(cityName:String, forDate searchDate:NSDate, completion:DayForecastCompletion) {
        
        // Check if we have recently cached data.
        if let data = self.forecastData,
           lastDate = self.lastForecastUpdate
            where lastDate.timeIntervalSinceNow < timeoutInterval {
            
            let calendar = calendarForWeatherDate()
            let dayData = self.forecastData?.filter {
                calendar.isDate($0.date, inSameDayAsDate: searchDate)
            }
            
            // Update caller
            dispatch_async(dispatch_get_main_queue()) {
                completion(dayData, nil)
            }
            return
        } else {
            // Make Network Request
            
        }
    }
    
    func getForecast(cityName:String, completion:FullForecastCompletion) {
        
        // Check if we have recently cached data.
        if let data = self.forecastData,
           lastDate = self.lastForecastUpdate
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
                self.decodeForecastData(data, error:error, completion:completion)
            }
        }
    }
    
    func decodeForecastData(data:NSData?, error:NSError?, completion:FullForecastCompletion) {
        
        guard let cityData = data else {
            print("Error getting forecast data from network")
            return
        }
        guard let decodedData = ForecastData.dataFromJSON("NAME", jsonData: cityData) else {
            print("Error decoding json data")
            return
        }
        // Set last update time.
        self.lastForecastUpdate = NSDate()
        self.forecastData = decodedData
        //self.printWeatherData(decodedData)
        let splitData = self.splitDataByDays(decodedData)
        // Update caller
        dispatch_async(dispatch_get_main_queue()) {
            completion(splitData, error)
        }
    }
    
    func calendarForWeatherDate() ->NSCalendar {
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "America/New_York")!
        return calendar
    }
    
    func splitDataByDays(weatherData:[ForecastData]) ->Array<[ForecastData]>{
        
        // Create calendar object with correct time zone.
        let calendar = calendarForWeatherDate()
        
        // Split data into arrays based on date.
        var days = Array<[ForecastData]>()
        var currentDay = [ForecastData]()
        var activeDate = weatherData.first!.date
        
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