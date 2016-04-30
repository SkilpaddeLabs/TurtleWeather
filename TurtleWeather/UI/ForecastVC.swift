//
//  ForecastVC.swift
//  TurtleWeather
//
//  Created by Tim Bolstad on 4/24/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

struct ForecastTableData {
    let date:NSDate
    let weather:String
    let loTemp:Float
    let hiTemp:Float
}

// Main view, displays today's current weather,
// as well as condensed forecast data for upcoming days.
class ForecastVC: UITableViewController {
    
    var dataCache:WeatherDataCache?
    var todayDate:NSDate?
    var todayCity:String = "New York,us" 
    
    var forecastTableData:[ForecastTableData]?
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
        // Register custom table view cells nibs.
        self.tableView.registerNib( UINib(nibName: "WeatherCell", bundle: nil),
                           forCellReuseIdentifier: "WeatherCell")
        self.tableView.registerNib( UINib(nibName: "ForecastCell", bundle: nil),
                           forCellReuseIdentifier: "ForecastCell")
        
        // Add refresh button. 
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Refresh,
                                                       target: self,
                                                       action: #selector(ForecastVC.refreshButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = rightButton
        
        // Get Data
        refreshData()
    }
    
    func refreshButtonPressed(sender:UIBarButtonItem) {
        refreshData()
    }
    
    func refreshData() {
        
        self.dataCache?.getWeather(todayCity) { (data, error) in
            
            if let anError = error {
                self.errorAlert(anError)
            }
            self.todayDate = NSDate()
            self.todayCity = data?.name ?? ""
            self.tableView.reloadData()
        }
        
        self.dataCache?.getForecast(todayCity) { (data, error) in
            
            if let anError = error {
                self.errorAlert(anError)
            }
            
            if let todayData = data?.first {
                // Save data needed for table display.
                self.forecastTableData = data!.map { dayData in
                    return self.processTableData(dayData)
                }
                self.todayDate = todayData.first?.date
                self.tableView.reloadData()
            }
        }
    }
    
    // Takes the full ForcastData array and returns an array of
    // just the data that is displayed in the table.
    func processTableData(dayData:[ForecastData]) ->ForecastTableData {
        
        if let firstDayData = dayData.first {
            
            let date = firstDayData.date
            let weather = firstDayData.weather
            let temps = dayData.map{ $0.tempKelvin }
            let hi = temps.maxElement() ?? 1.0
            let lo = temps.minElement() ?? 0.0
            return ForecastTableData(date: date, weather: weather, loTemp: lo, hiTemp: hi)
        }
        else {
            return ForecastTableData(date: NSDate.distantPast(), weather: "", loTemp: 0.0, hiTemp: 1.0)
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
        
        if let someData = self.forecastTableData {
            return someData.count
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // TODO: - More flexible heights.
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
            fCell.forecastLabel.adjustsFontSizeToFitWidth = true
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
        
        if let currentData = self.dataCache?.weatherData {
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
        
        if let cellData = forecastTableData?[index] {
            
            let formattedDate = dateFormatter(withTime: false).stringFromDate(cellData.date)
            let dateString = index > 1 ? formattedDate : "Tomorrow"
            let formatHigh = Temperature.Fahrenheit.convertKelvin(cellData.hiTemp)
            let formatLow = Temperature.Fahrenheit.convertKelvin(cellData.loTemp)
            let formatText = "\(dateString)   \(cellData.weather)   Lo: \(formatLow)   Hi: \(formatHigh)"
            
            cell.forecastLabel.text = formatText
        }
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
