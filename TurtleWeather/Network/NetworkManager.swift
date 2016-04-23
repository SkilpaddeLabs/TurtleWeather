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

    init() {
//        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//        afManager = Alamofire.Manager(configuration: config)
    }
    
    typealias londonCompletion = (NSData?)->(Void)
    class func getLondon(completion:londonCompletion) {
        
        
        Alamofire.request(OWM_APIRouter.City("London"))
                 .validate()
                 .response { (request, response, data, error) in
        
            // TODO: Check response for error
            if let urlResponse = response {
                //print(urlResponse)
                //return
            }
            // TODO: Do something with errors
            if let anError = error {
                print(anError)
                return
            }
            completion(data)
        }
    }
}