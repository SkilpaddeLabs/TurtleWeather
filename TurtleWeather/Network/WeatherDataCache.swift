//
//  WeatherDataCache.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/21/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation
import Alamofire


// Makes network requests and stores data.
//  Notifies UI that data has been updated.
//  UI objects talk to the cache only, do not
//  make network requests themselves.
class WeatherDataCache {
    
    init() {
        
    }
    
    func getLondon() {
        
        NetworkManager.getLondon { data in
            if let londonData = data {
                self.printLondon(londonData)
            }
        }
    }
    
    func printLondon(data:NSData) {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                            as? [String:AnyObject] {
                
                if let aList = json["list"] as? [[String:AnyObject]] {
                    //aWeather = aList{
                    for thing in aList {
                        print(thing["wind"])
                    }
                }
            }
        } catch {
            print("Error Printing London")
        }
    }
}