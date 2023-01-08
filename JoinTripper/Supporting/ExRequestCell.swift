//
//  ExRequestCell.swift
//  JoinTripper
//
//  Created by Dario Corral on 29/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import CircleLabel

class ExRequestCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var flightLabel: UILabel!
    @IBOutlet var airlineLabel: UILabel!
    @IBOutlet var airportLabel: UILabel!
    @IBOutlet var matches: CircleLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Adjust Label text size
        self.dateLabel.adjustsFontForContentSizeCategory = true
        self.dateLabel.adjustsFontSizeToFitWidth = true
        let dateLabelHeight = dateLabel.optimalHeight
        dateLabel.frame = CGRect(x: dateLabel.frame.origin.x, y: dateLabel.frame.origin.y, width: dateLabel.frame.width, height: dateLabelHeight)
        
        self.flightLabel.adjustsFontForContentSizeCategory = true
        self.flightLabel.adjustsFontSizeToFitWidth = true
        let flightLabelHeight = flightLabel.optimalHeight
        flightLabel.frame = CGRect(x: flightLabel.frame.origin.x, y: flightLabel.frame.origin.y, width: flightLabel.frame.width, height: flightLabelHeight)
        
        self.airlineLabel.adjustsFontForContentSizeCategory = false
        self.airlineLabel.adjustsFontSizeToFitWidth = true
        let airlineLabelHeight = airlineLabel.optimalHeight
        airlineLabel.frame = CGRect(x: airlineLabel.frame.origin.x, y: airlineLabel.frame.origin.y, width: airlineLabel.frame.width, height: airlineLabelHeight)

        
        self.airportLabel.adjustsFontForContentSizeCategory = false
        self.airportLabel.adjustsFontSizeToFitWidth = true
        let airportLabelHeight =  airportLabel.optimalHeight
        airportLabel.frame = CGRect(x:  airportLabel.frame.origin.x, y:  airportLabel.frame.origin.y, width:  airportLabel.frame.width, height:  airportLabelHeight)
        
        //Jointripper Color
        let joinTripperColor = ColorHex.hexStringToUIColor(hex: "#A178DE")
        
        //Generate color based on text or user defined parameter
        matches.useTextColor = false;
        
        //If useTextColor == false - this value will be used for circle color
        matches.circleColor = joinTripperColor
        
        //Change text color
        matches.textColor = UIColor.white
        
        self.layoutIfNeeded()
        
    }
}
