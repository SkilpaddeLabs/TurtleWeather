//
//  CurrentWeatherVC.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/24/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

class CurrentWeatherVC: UIViewController {

    
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var tomorrowView: UIView!
    @IBOutlet weak var dayAfterTomorrowView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var tomorrowLabel: UILabel!
    @IBOutlet weak var dayAfterTomorrowLabel: UILabel!
    
    weak var dataCache:WeatherDataCache?
    
    
    // MARK: - Segues
    @IBAction func showDetail(sender: UIButton) {
        
        let buttonNumber = NSNumber(int:Int32(sender.tag))
        
        self.performSegueWithIdentifier("ShowDetailSegue", sender: buttonNumber)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetailSegue" {
            
            if let buttonNumber = sender?.intValue {
                print("Butt: \(buttonNumber)")
            }
            // Inject dataCache dependancy.
            if let destination = segue.destinationViewController as? WeatherDetailVC {
                destination.dataCache = self.dataCache
            }
        }
    }
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let dataCache = WeatherDataCache()
        dataCache.getWeather("London") { (data, error) in
            
            if let todayData = data?.first {
                self.updateTodayUI(todayData)
            }
            if let tomorrowData = data?[1] {
                self.tomorrowLabel.text = self.weatherString("Tomorrow", weatherData:tomorrowData)
            }
            if let nextDayData = data?[2] {
                self.dayAfterTomorrowLabel.text = self.weatherString("Next Day", weatherData:nextDayData)
            }
        }
        roundCorners()
    }
    
    func roundCorners() {
        
        todayView.layer.cornerRadius = 10.0
        tomorrowView.layer.cornerRadius = 10.0
        dayAfterTomorrowView.layer.cornerRadius = 10.0
    }
    
    func updateTodayUI(data:[WeatherData]) {
        
        guard let currentData = data.first else {
            return
        }
        
        let dateFormatter = self.dateFormatter()
        self.nameLabel.text = "\(currentData.name)"
        self.dateLabel.text = dateFormatter.stringFromDate(currentData.date)
        self.temperatureLabel.text = Temperature.Fahrenheit.convertKelvin(currentData.tempKelvin)
        self.weatherLabel.text = "\(currentData.weather)"
    }
    
    func weatherString(day:String, weatherData:[WeatherData]) ->String {
        
        let weatherString = weatherData.first?.weather ?? ""
        
        let temps = weatherData.map{ $0.tempKelvin }
        let highTemp = temps.maxElement() ?? 0.0
        let lowTemp = temps.minElement()  ?? 0.0
        
        let formatHigh = Temperature.Fahrenheit.convertKelvin(highTemp)
        let formatLow = Temperature.Fahrenheit.convertKelvin(lowTemp)
        
        return "\(day) - \(weatherString) Hi: \(formatHigh) Lo: \(formatLow)"
    }
    
    func dateFormatter() ->NSDateFormatter {
        
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
