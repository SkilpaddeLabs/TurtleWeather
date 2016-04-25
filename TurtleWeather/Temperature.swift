//
//  Temperature.swift
//  TurtleWeather
//
//  Created by bolstad on 4/25/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import Foundation

enum Temperature {
    
    case Celsius, Fahrenheit
    
    func convertKelvin(kTemp:Float) ->String {
        
        let formatter = NSNumberFormatter()
        
        switch self {
        case .Celsius:
            let cTemp = kTemp+237.15
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            return "\(formatter.stringFromNumber(cTemp) ?? "_") C"
        case .Fahrenheit:
            let fTemp = (kTemp * 9.0 / 5.0) - 459.67
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
            return "\(formatter.stringFromNumber(fTemp) ?? "_") F"
        }
    }
}