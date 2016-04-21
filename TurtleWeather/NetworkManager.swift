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
    static let APIKEY =  "XXXXXXXXXXX"

    init() {
//        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//        afManager = Alamofire.Manager(configuration: config)
    }
    
    func getLondonUS() {
        
        let urlString = "http://api.openweathermap.org/data/2.5/forecast"
        let parameters = ["q":"London", "APPID":NetworkManager.APIKEY]
        let headers = ["Accept":"application/json"]
        Alamofire.request( .GET, urlString, parameters: parameters, headers: headers)
                 .validate()
                 .responseJSON { response in
            
                    guard response.result.isSuccess else {
                        print(response.result.error)
                        return
                    }
                    
                    print(response.result.value)
        }
        
        
        //http://api.openweathermap.org/data/2.5/forecast?q=London,us&mode=json
    }
}