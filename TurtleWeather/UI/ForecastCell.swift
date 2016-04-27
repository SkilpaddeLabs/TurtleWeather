//
//  ForecastCell.swift
//  TurtleWeather
//
//  Created by bolstad on 4/27/16.
//  Copyright © 2016 Skilpadde Labs. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {

    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var forecastLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        weatherView.layer.cornerRadius = 10.0
    }
}
