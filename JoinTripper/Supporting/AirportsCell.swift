//
//  AirportsCell.swift
//  JoinTripper
//
//  Created by Dario Corral on 13/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

class AirportsCell: UITableViewCell {
    
    @IBOutlet var code: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var distance: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        code.adjustsFontForContentSizeCategory = true
        name.adjustsFontForContentSizeCategory = true
        distance.adjustsFontForContentSizeCategory = true
        
    }
    
}

