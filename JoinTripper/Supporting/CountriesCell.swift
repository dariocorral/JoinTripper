//
//  CountriesCell.swift
//  JoinTripper
//
//  Created by Dario Corral on 19/01/2019.
//  Copyright © 2019 Dario Corral. All rights reserved.
//

import UIKit

class CountriesCell: UITableViewCell {
    
    @IBOutlet var code: UILabel!
    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        code.adjustsFontForContentSizeCategory = false
        name.adjustsFontForContentSizeCategory = false
        
    }
    
    
}
