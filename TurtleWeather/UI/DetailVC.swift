//
//  DetailVC.swift
//  TurtleWeather
//
//  Created by bolstad on 4/25/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

class DetailVC: UITableViewController {

    weak var dataCache:WeatherDataCache?
    var todayDate:NSDate?
    var todayData:[ForecastData]?
    var todayCity:String?
    
    // MARK: - View Loading
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.registerNib( UINib(nibName: "ForecastCell", bundle: nil),
                           forCellReuseIdentifier: "ForecastCell")
        loadData()
    }
 
    // MARK: - Get data.
    func loadData() {
        
        if let aDay = todayDate,
              aCity = todayCity {
            
            dataCache?.getForecast(aCity, forDate:aDay) { (data, error) in
                
                self.todayData = data
                self.tableView.reloadData()
            }
        }
    }
    
    // Extracts Hour String from date
    func hourFormatter() ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/New_York")
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }
    
    func dateFormatter() ->NSDateFormatter {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeZone = NSTimeZone(name: "America/New_York")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }

    // MARK: - UITableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let aDate = todayData?.first?.date {
            return dateFormatter().stringFromDate(aDate)
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayData?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier( "ForecastCell",
                                                  forIndexPath: indexPath) as! ForecastCell
        
        if let data = todayData?[indexPath.row] {
            let hour = "\(hourFormatter().stringFromDate(data.date))"
            let temp = Temperature.Fahrenheit.convertKelvin(data.tempKelvin)
            cell.forecastLabel.text = "\(hour) - \(temp) - \(data.weatherDescription)"
        }
        return cell
    }
}
