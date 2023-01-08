//
//  FlightsPoolCell.swift
//  JoinTripper
//
//  Created by Dario Corral on 17/11/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

class FlightsPoolCell: UITableViewCell {
    
    @IBOutlet var price: UILabel!
    @IBOutlet var mainAirline: UILabel!
    @IBOutlet var flights: UILabel!
    @IBOutlet var duration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        price.adjustsFontForContentSizeCategory = true
        mainAirline.adjustsFontForContentSizeCategory = true
        flights.adjustsFontForContentSizeCategory = true
        duration.adjustsFontForContentSizeCategory = true
                
    }
    
    
}
