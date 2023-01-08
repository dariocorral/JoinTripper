//
//  FlightDetailCell.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

class FlightDetailCell: UITableViewCell {
    @IBOutlet var airline: UILabel!
    @IBOutlet var flightCode: UILabel!
    @IBOutlet var departureDateTime: UILabel!
    @IBOutlet var arrivalDateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        airline.adjustsFontForContentSizeCategory = true
        flightCode.adjustsFontForContentSizeCategory = true
        departureDateTime.adjustsFontForContentSizeCategory = true
        arrivalDateTime.adjustsFontForContentSizeCategory = true
        
    }
    
    
}
