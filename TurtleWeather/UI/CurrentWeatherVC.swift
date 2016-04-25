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
        // Do any additional setup after loading the view, typically from a nib.
        let dataCache = WeatherDataCache()
        dataCache.getWeather("London") { (data, error) in
            
            if let lastData = data?.first?.first {
                self.nameLabel.text = "\(lastData.name)"
                self.dateLabel.text = "\(lastData.date)"
                self.temperatureLabel.text = "\(lastData.tempKelvin)"
                self.weatherLabel.text = "\(lastData.weather)"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
