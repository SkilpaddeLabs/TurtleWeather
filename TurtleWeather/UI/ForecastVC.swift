//
//  ForecastVC.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/24/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

class ForecastVC: UITableViewController {
    
    var dataCache:WeatherDataCache?
    var todayDate:NSDate?
    var todayCity:String = "New York,us" 
    
    // TODO: nope
    var forecastData:Array<[ForecastData]>?
    var weatherData:ForecastData?
    var showingAlert:Bool = false
    
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
                if let destination = segue.destinationViewController as? DetailVC {
                    
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
        
        self.tableView.registerNib( UINib(nibName: "WeatherCell", bundle: nil),
                           forCellReuseIdentifier: "WeatherCell")
        self.tableView.registerNib( UINib(nibName: "ForecastCell", bundle: nil),
                           forCellReuseIdentifier: "ForecastCell")
        
        self.dataCache = WeatherDataCache()
        self.dataCache?.getForecast(todayCity) { (data, error) in
            
            if let anError = error {
                self.errorAlert(anError)
            }
            
            if let todayData = data?.first {
                self.forecastData = data!
                self.todayDate = todayData.first?.date
                self.tableView.reloadData()
            }
        }
        
        self.dataCache?.getWeather(todayCity) { (data, error) in
            
            if let anError = error {
                self.errorAlert(anError)
            }
            
            self.weatherData = data
            self.todayDate = NSDate()
            self.todayCity = data?.name ?? ""
            self.tableView.reloadData()
        }
    }
    
    func errorAlert(anError:NSError) {
        
        print("Error: \(anError.code) \(anError.domain) \(anError.localizedDescription)")
        guard showingAlert == false else { return }
        
        var title:String = "Unknown Error"
        if let description = anError.userInfo[NSLocalizedDescriptionKey] as? String {
            title = description
        }
        var message:String = ""
        if let recoveryOptions = anError.userInfo[NSLocalizedRecoveryOptionsErrorKey] as? String {
            message = recoveryOptions
        }
        
        let alert = UIAlertController(title: title,
                                    message: message,
                             preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK",
                                     style: .Cancel,
                                   handler: nil)
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true) { self.showingAlert = false }
        showingAlert = true
    }
    
    // MARK: - UITableViewDelegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let someData = forecastData {
            return someData.count
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 400.0
        } else {
            return 90.0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell
        if indexPath.row == 0 {
            
            let wCell = tableView.dequeueReusableCellWithIdentifier( "WeatherCell",
                                            forIndexPath: indexPath) as! WeatherCell
            
            updateWeatherCell(wCell)
            cell = wCell
            
        } else {
        
            let fCell = tableView.dequeueReusableCellWithIdentifier( "ForecastCell",
                                                  forIndexPath: indexPath) as! ForecastCell
            
            updateForecastCell(fCell, atIndex: indexPath.row)
            cell = fCell
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        runDetailSegue(indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - Utility
    func updateWeatherCell(cell:WeatherCell) {
        
        // TODO: Weather API not forecast
        if let currentData = weatherData {
            cell.nameLabel.text = "\(currentData.name)"
            cell.dateLabel.text = dateFormatter().stringFromDate(currentData.date)
            cell.temperatureLabel.text = Temperature.Fahrenheit.convertKelvin(currentData.tempKelvin)
            cell.weatherLabel.text = "\(currentData.weather)"
            if let aSunrise = currentData.sunrise,
               let aSunset = currentData.sunset {
                
                let formatter = hourFormatter()
                let sunriseString = formatter.stringFromDate(aSunrise)
                let sunsetString = formatter.stringFromDate(aSunset)
                cell.sunriseLabel.text = "Sunrise: \(sunriseString)"
                cell.sunsetLabel.text = "Sunset: \(sunsetString)"
            } else {
                cell.sunriseLabel.text = ""
                cell.sunsetLabel.text = ""
            }
            
            cell.humidityLabel.text = "Humidity: \(currentData.humidity)%"
            cell.pressureLabel.text = "Pressure: \(currentData.pressure) hpa"
        } else {
            cell.nameLabel.text = "-"
            cell.dateLabel.text = "-"
            cell.temperatureLabel.text = "-"
            cell.weatherLabel.text = "-"
            
            cell.sunriseLabel.text = "-"
            cell.sunsetLabel.text = "-"
            cell.humidityLabel.text = "-"
            cell.pressureLabel.text = "-"
        }
    }
    
    func updateForecastCell(cell:ForecastCell, atIndex index:Int) {
        
        if let dayData = forecastData?[index] {
            
            let formattedDate = dateFormatter(withTime: false).stringFromDate(dayData.first!.date)
            let dateString = index > 1 ? formattedDate : "Tomorrow"
            cell.forecastLabel.text = self.weatherString(dateString, weatherData:dayData)
            cell.forecastLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    func weatherString(day:String, weatherData:[ForecastData]) ->String {
        
        let weatherString = weatherData.first?.weather ?? ""
        
        let temps = weatherData.map{ $0.tempKelvin }
        let highTemp = temps.maxElement() ?? 0.0
        let lowTemp = temps.minElement()  ?? 0.0
        
        let formatHigh = Temperature.Fahrenheit.convertKelvin(highTemp)
        let formatLow = Temperature.Fahrenheit.convertKelvin(lowTemp)
        
        return "\(day)   \(weatherString)   Lo: \(formatLow)   Hi: \(formatHigh)"
    }
    
    func dateFormatter(withTime withTime:Bool = true) ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        if withTime {
            dateFormatter.timeStyle = .ShortStyle
        }
        dateFormatter.timeZone = NSTimeZone(name: "America/New_York")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }
    
    func hourFormatter() ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        // TODO: set timezone variable
        dateFormatter.timeZone = NSTimeZone(name: "America/New_York")
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
