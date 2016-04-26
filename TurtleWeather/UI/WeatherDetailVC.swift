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
    
    // MARK: - View Loading
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadData()
    }
 
    // MARK: - Get data.
    func loadData() {
        
        // TODO !
        let tomorrow = todayDate!.dateByAddingTimeInterval(24*60*60)
        dataCache?.getWeather( "London", forDate:tomorrow) { (data, error) in
            
            self.todayData = data
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
