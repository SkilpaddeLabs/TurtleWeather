//
//  WeatherDetailVC.swift
//  TurtleWeather
//
//  Created by bolstad on 4/25/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

class WeatherDetailVC: UITableViewController {

    weak var dataCache:WeatherDataCache?
    var todayDate:NSDate?
    var todayData:[WeatherData]?
    var todayCity:String?
    
    // MARK: - View Loading
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadData()
    }
 
    // MARK: - Get data.
    func loadData() {
        
        if let aDay = todayDate,
              aCity = todayCity {
            
            dataCache?.getWeather( aCity, forDate:aDay) { (data, error) in
                
                self.todayData = data
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(todayData?.first?.date ?? "")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayData?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier( "DetailCell",
                                                  forIndexPath: indexPath)
    
        cell.textLabel?.text = "\(todayData?[indexPath.row].date)"
        return cell
    }
}
