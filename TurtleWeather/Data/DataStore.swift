//
//  File.swift
//  TurtleWeather
//
//  Created by bolstad on 4/28/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Core Data Saving support
class DataStore {
    
    // MARK: Weather
    func saveWeather(weatherData:ForecastData) {
        
        let managedContext = self.managedObjectContext
        // Delete any existing weather data
        deleteWeather()
        // Create new managed object.
        let entityDescription = ForecastRecord.entityDescription(managedContext)
        let newRecord = ForecastRecord(entity: entityDescription!,
               insertIntoManagedObjectContext: managedContext)
        newRecord.store(weatherData, isWeather:true)
        
        // Try saving.
        self.saveContext("SAVE WEATHER")
    }
    
    func loadWeather() ->ForecastData? {
        
        let managedContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isWeather == TRUE")
        fetchRequest.entity = NSEntityDescription.entityForName("ForecastRecord",
                                         inManagedObjectContext: managedContext)
        
        do {
            // Try creating a ForecastData struct from loaded data.
            let weatherData = try managedContext.executeFetchRequest(fetchRequest)
            if let savedWeather = weatherData.first as? ForecastRecord {
                
                return savedWeather.retrieve()
            }
        } catch let error as NSError {
            print("Could not retreive saved data. \(error)")
        }
        return nil
    }
    
    func deleteWeather() {
        
        let managedContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isWeather == TRUE")
        fetchRequest.entity = NSEntityDescription.entityForName("ForecastRecord",
                                         inManagedObjectContext: managedContext)
        // Fetch existing weather data
        var oldWeather:ForecastRecord? = nil
        do {
            let weatherData = try managedContext.executeFetchRequest(fetchRequest)
            oldWeather = weatherData.first as? ForecastRecord
            
        } catch let error as NSError {
            print("Could not retreive saved data. \(error)")
        }
        // Delete
        if let deleteRecord = oldWeather {
            managedContext.deleteObject(deleteRecord)
            self.saveContext("DELETE WEATHER")
        }
    }
    
    // MARK: Forecast
    func saveForecast(forecastData:[ForecastData]) {
        
        let managedContext = self.managedObjectContext
        // Delete any existing weather data
        deleteForecast()
        // Create new array of managed objects.
        let entityDescription = ForecastRecord.entityDescription(managedContext)
        for data in forecastData {
           let newRecord = ForecastRecord(entity: entityDescription!,
                  insertIntoManagedObjectContext: managedContext)
            newRecord.store(data)
        }
        // Try saving.
        self.saveContext("SAVE FORECAST")
    }
    
    func loadForecast() ->[ForecastData]? {
        
        let managedContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "isWeather == FALSE")
        fetchRequest.entity = NSEntityDescription.entityForName("ForecastRecord",
                                         inManagedObjectContext: managedContext)
        do {
            // Try creating a ForecastData struct from loaded data.
            let forecastData = try managedContext.executeFetchRequest(fetchRequest)
            if let savedForecast = forecastData as? [ForecastRecord] {
                
                // Convert Managed Objects into array of structs.
                return savedForecast.map{ $0.retrieve() }
            }
        } catch let error as NSError {
            print("Could not retreive saved data. \(error)")
        }
        return nil
    }
    
    func deleteForecast() {
        
        let managedContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isWeather == FALSE")
        fetchRequest.entity = NSEntityDescription.entityForName("ForecastRecord",
                                         inManagedObjectContext: managedContext)
        // Fetch existing weather data
        var oldForecast:[AnyObject]? = nil
        do {
            oldForecast = try managedContext.executeFetchRequest(fetchRequest)
            
        } catch let error as NSError {
            print("Could not retreive saved data. \(error)")
        }
        // Delete
        if let deleteRecords = oldForecast as? [ForecastRecord] {
            for record in deleteRecords {
                managedContext.deleteObject(record)
            }
            self.saveContext("DELETE FORECAST")
        }
    }
    
    // MARK: Save Context
    func saveContext (errorString:String) {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("\(errorString) \(error)")
            }
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.skilpaddelabs.TurtleWeather" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ForecastRecord", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}