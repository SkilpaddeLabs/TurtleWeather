//
//  ForecastVC.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/24/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

class ForecastVC: UIViewController,
    UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var forecastTableView: UITableView!
    
    var dataCache:WeatherDataCache?
    var todayDate:NSDate?
    var todayCity:String = "London"
    
    // TODO: nope
    var forecastData:Array<[ForecastData]>?
    
    // MARK: - Segues
    @IBAction func showDetail(sender: UIButton) {
        
        runDetailSegue(sender.tag)
    }
    
    func runDetailSegue(index:Int) {
        let buttonNumber = NSNumber(int:Int32(index))
        self.performSegueWithIdentifier("ShowDetailSegue", sender: buttonNumber)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetailSegue" {
            
            if let buttonNumber = sender?.intValue {
                
                // Pass date depending on which button was pushed.
                let interval = Double(buttonNumber*24*60*60)
                let destinationDate = todayDate?.dateByAddingTimeInterval(interval)
                
                // Inject dataCache dependancy.
                if let destination = segue.destinationViewController as? WeatherDetailVC {
                    
                    destination.dataCache = self.dataCache
                    destination.todayDate = destinationDate
                    destination.todayCity = self.todayCity
                }
            }
        }
    }
    
    // MARK: - View Loading
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.todayCity = "London"
        
        self.dataCache = WeatherDataCache()
        self.dataCache?.getForecast(todayCity) { (data, error) in
            
            if let todayData = data?.first {
                self.forecastData = data!
                self.todayDate = todayData.first?.date
                self.updateWeatherUI(todayData)
                self.forecastTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        roundCorners()
    }
    
    func roundCorners() {
        
        weatherView.layer.cornerRadius = 10.0
    }
    
    func updateWeatherUI(data:[ForecastData]) {
        
        guard let currentData = data.first else {
            return
        }
        
        self.nameLabel.text = "\(currentData.name)"
        self.dateLabel.text = dateFormatter().stringFromDate(currentData.date)
        self.temperatureLabel.text = Temperature.Fahrenheit.convertKelvin(currentData.tempKelvin)
        self.weatherLabel.text = "\(currentData.weather)"
    }
    // MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let someData = forecastData {
            return someData.count - 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier( "ForecastCell",
                                                                forIndexPath: indexPath)
        cell.contentView.backgroundColor = weatherView.backgroundColor
        cell.contentView.layer.cornerRadius = 10.0
        
        
        if let dayData = forecastData?[indexPath.row + 1] {
            
            cell.textLabel?.backgroundColor = weatherView.backgroundColor
            
            let formattedDate = dateFormatter(withTime: true).stringFromDate(dayData.first!.date)
            let dateString = indexPath.row > 0 ? formattedDate : "Tomorrow"
            cell.textLabel?.text = self.weatherString(dateString, weatherData:dayData)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        runDetailSegue(indexPath.row + 1)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - Utility
    func weatherString(day:String, weatherData:[ForecastData]) ->String {
        
        let weatherString = weatherData.first?.weather ?? ""
        
        let temps = weatherData.map{ $0.tempKelvin }
        let highTemp = temps.maxElement() ?? 0.0
        let lowTemp = temps.minElement()  ?? 0.0
        
        let formatHigh = Temperature.Fahrenheit.convertKelvin(highTemp)
        let formatLow = Temperature.Fahrenheit.convertKelvin(lowTemp)
        
        return "\(day) - \(weatherString) Hi: \(formatHigh) Lo: \(formatLow)"
    }
    
    func dateFormatter(withTime withTime:Bool = true) ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        if withTime {
            dateFormatter.timeStyle = .ShortStyle
        }
        dateFormatter.timeZone = NSTimeZone(name: "Europe/London")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
