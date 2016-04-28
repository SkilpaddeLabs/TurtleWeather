//
//  ForecastRecord+CoreDataProperties.swift
//  TurtleWeather
//
//  Created by bolstad on 4/28/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ForecastRecord {

    @NSManaged var date: NSTimeInterval
    @NSManaged var humidity: Float
    @NSManaged var name: String?
    @NSManaged var pressure: Float
    @NSManaged var rain: Float
    @NSManaged var sunrise: NSTimeInterval
    @NSManaged var sunset: NSTimeInterval
    @NSManaged var tempKelvin: Float
    @NSManaged var weather: String?
    @NSManaged var weatherDescription: String?
    @NSManaged var windDirection: Float
    @NSManaged var windSpeed: Float
    @NSManaged var isWeather: Bool

}
