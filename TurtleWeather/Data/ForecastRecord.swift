//
//  ForecastRecord.swift
//  TurtleWeather
//
//  Created by bolstad on 4/28/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import CoreData


class ForecastRecord: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func store(data: ForecastData, isWeather:Bool = false) {
        
        self.date = data.date.timeIntervalSince1970
        self.humidity = data.humidity
        self.name = data.name
        self.pressure = data.pressure
        self.rain = data.rain
        self.sunrise = data.sunrise?.timeIntervalSince1970 ?? 0
        self.sunset = data.sunset?.timeIntervalSince1970 ?? 0
        self.tempKelvin = data.tempKelvin
        self.weather = data.weather
        self.weatherDescription = data.weatherDescription
        self.windDirection = data.windDirection
        self.windSpeed = data.windSpeed
        self.isWeather = isWeather
    }
    
    func retrieve() ->ForecastData {
        
        return ForecastData(date: NSDate.init(timeIntervalSince1970: self.date),
                            rain: self.rain,
                      tempKelvin: self.tempKelvin,
                        humidity: self.humidity,
                        pressure: self.pressure,
                   windDirection: self.windDirection,
                       windSpeed: self.windSpeed,
                         weather: self.weather ?? "",
              weatherDescription: self.weatherDescription ?? "",
                            name: self.name ?? "",
                         sunrise: NSDate.init(timeIntervalSince1970: self.sunrise),
                          sunset: NSDate.init(timeIntervalSince1970: self.sunset))
    }
    
    class func entityDescription(context:NSManagedObjectContext) ->NSEntityDescription? {
        
        return NSEntityDescription.entityForName("ForecastRecord",
                          inManagedObjectContext: context)
    }
}
