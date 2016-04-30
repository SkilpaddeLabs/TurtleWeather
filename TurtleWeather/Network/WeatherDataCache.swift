//
//  WeatherDataCache.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/21/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import Alamofire

typealias FullForecastCompletion = (Array<[ForecastData]>?, NSError?)->(Void)
typealias DayForecastCompletion = ([ForecastData]?, NSError?)->(Void)
typealias WeatherCompletion = (ForecastData?, NSError?)->(Void)

// Makes network requests and stores data.
//  Notifies UI that data has been updated.
//  UI objects talk to the cache only, do not
//  make network requests themselves.
class WeatherDataCache {
    
    let timeoutInterval = 15.0 //* 60.0
    var lastWeatherUpdate:NSDate?
    var lastForecastUpdate:NSDate?
    var weatherData:ForecastData?
    var forecastData:[ForecastData]?
    var dataStore:DataStore?
    
    // TODO: Serial/Concurrent ???
    let networkQueue = dispatch_queue_create("com.turtleweather.network", DISPATCH_QUEUE_SERIAL)

    init() {
        
    }
    
    // Returns today's weather data from the network if possible.
    // otherwise it returns saved data from disk.
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
            NetworkManager.getWeather(cityName) { result in
                
                switch result {
                // If successful decode data.
                case .Success(let data):
                    self.decodeWeatherData(data, error: nil, completion: completion)
                case .Failure(let error):
                    // Check to see if there is data on disk.
                    if let savedData = self.dataStore?.loadWeather() {
                        self.weatherData = savedData
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(savedData, error)
                        }
                    } else {
                        // Finally, failure.
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    // Returns all the forecast events.
    func getForecast(cityName:String, completion:FullForecastCompletion) {
        
        // Check if we have recently cached data.
        if let data = self.forecastData,
           lastDate = self.lastForecastUpdate
           where (!data.isEmpty) && (lastDate.timeIntervalSinceNow < timeoutInterval) {
           
            let splitData = self.splitDataByDays(data)
            // Update caller
            dispatch_async(dispatch_get_main_queue()) {
                completion(splitData, nil)
            }
            return
        }
        // Make network request.
        dispatch_async(networkQueue) {
            
            NetworkManager.getForecast(cityName) { result in
                
                // If network request successful decode data.
                switch result {
                case .Success(let data):
                    self.decodeForecastData(data, error: nil, completion:completion)
                case .Failure(let error):
                    // Check to see if there is data on disk.
                    if let savedData = self.dataStore?.loadForecast()
                     where !savedData.isEmpty {
                        self.forecastData = savedData
                        let splitData = self.splitDataByDays(savedData)
                        // Update caller
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(splitData, error)
                        }
                    } else {
                        // Finally, failure.
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    // Returns all the forecast events for a given date.
    // TODO: Don't need to return the whole array of ForecastData
    //      Just need to return what is displayed in the UITableView.
    func getForecast(cityName:String, forDate searchDate:NSDate, completion:DayForecastCompletion) {
        
        let calendar = calendarForWeatherDate()
        // Check if we have recently cached data.
        if let existingData = self.forecastData,
            lastDate = self.lastForecastUpdate
            where lastDate.timeIntervalSinceNow < timeoutInterval {
            
            let dayData = self.filterDates(calendar, inData: existingData, filterDate: searchDate)
            // Update UI
            dispatch_async(dispatch_get_main_queue()) {
                completion(dayData, nil)
            }
            return
        } else {
            // Make Network Request
            self.getForecast(cityName) { (freshData, error) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let freshData = self.forecastData {
                        // Filter by date
                        let dayData = self.filterDates(calendar, inData: freshData, filterDate: searchDate)
                        // Update UI
                        completion(dayData, error)
                    }
                }
            }
        }
    }
    
    // MARK: - Decoding network results.
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
        // Persist to disk
        if let someWeatherData = self.weatherData {
            self.dataStore?.saveWeather(someWeatherData)
        }
        // Update caller
        dispatch_async(dispatch_get_main_queue()) {
            completion(self.weatherData, error)
        }
    }
    
    func decodeForecastData(data:NSData?, error:NSError?, completion:FullForecastCompletion) {
        
        guard let cityData = data else {
            print("Error getting forecast data from network")
            return
        }
        guard let decodedData = ForecastData.dataFromJSON("NAME", jsonData: cityData)
            where !decodedData.isEmpty else {
            print("Error decoding json data")
            return
        }
        // Set last update time.
        self.lastForecastUpdate = NSDate()
        self.forecastData = decodedData
        // Persist to disk
        if let someForecastData = self.forecastData {
            self.dataStore?.saveForecast(someForecastData)
        }
        let splitData = self.splitDataByDays(decodedData)
        // Update caller
        dispatch_async(dispatch_get_main_queue()) {
            completion(splitData, error)
        }
    }
    
    // MARK: - Utility
    func calendarForWeatherDate() ->NSCalendar {
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "America/New_York")!
        return calendar
    }
    
    // Filters array of ForecastData and returns another array that only contains the given date
    func filterDates(calendar:NSCalendar, inData:[ForecastData], filterDate:NSDate) ->[ForecastData] {
        
        return inData.filter { calendar.isDate($0.date, inSameDayAsDate: filterDate) }
    }
    
    // Splits array of ForecastData by date into an array of arrays.
    func splitDataByDays(weatherData:[ForecastData]) ->Array<[ForecastData]>{
        
        // Create calendar object with correct time zone.
        let calendar = calendarForWeatherDate()
        
        // Split data into arrays based on date.
        var days = Array<[ForecastData]>()
        var currentDay = [ForecastData]()
        var activeDate = weatherData.first?.date ?? NSDate.distantPast()
        
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