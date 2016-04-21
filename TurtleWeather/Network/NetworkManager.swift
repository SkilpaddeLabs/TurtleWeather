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

    //var afManager:Alamofire.Manager
    
    // http://openweathermap.org
    static let APPID = "get your own id"

    init() {
//        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//        afManager = Alamofire.Manager(configuration: config)
    }
    
    func getLondonUS() {
        
        // http://api.openweathermap.org/data/2.5/forecast?q=London,us&mode=json
        let urlString = "http://api.openweathermap.org/data/2.5/forecast"
        let parameters = ["q":"London", "APPID":NetworkManager.APPID]
        let headers = ["Accept":"application/json"]
        Alamofire.request( .GET, urlString, parameters: parameters, headers: headers)
                 .validate()
                 .response{ (request, response, data, error) in
            
                    //response.result.value
                    if data != nil {
                        self.printLondon(data!)
                    }
        }
    }
    
    func printLondon(data:NSData) {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                as? [String:AnyObject] {
                //print(json["city"])
//                print(json["city"])
//                print(json["cod"])
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