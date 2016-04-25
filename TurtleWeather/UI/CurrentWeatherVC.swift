//
//  CurrentWeatherVC.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/24/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

class CurrentWeatherVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    weak var dataCache:WeatherDataCache?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let dateFormatter = CurrentWeatherVC.dateFormatter()
        
        let dataCache = WeatherDataCache()
        dataCache.getWeather("London") { (data, error) in
            
            if let lastData = data?.first?.first {
                self.nameLabel.text = "\(lastData.name)"
                self.dateLabel.text = dateFormatter.stringFromDate(lastData.date)
                self.temperatureLabel.text = Temperature.Fahrenheit.convertKelvin(lastData.tempKelvin)
                self.weatherLabel.text = "\(lastData.weather)"
            }
        }
    }
    
    class func dateFormatter() ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
