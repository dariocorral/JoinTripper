//
//  MatchExRequestCell.swift
//  JoinTripper
//
//  Created by Dario Corral on 30/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

class MatchExRequestCell: UITableViewCell {
    
    @IBOutlet var username: UILabel!
    @IBOutlet var gender: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var positiveVotes: UILabel!
    @IBOutlet var negativeVotes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        username.adjustsFontForContentSizeCategory = false
        gender.adjustsFontForContentSizeCategory = false
        age.adjustsFontForContentSizeCategory = false
        country.adjustsFontForContentSizeCategory = false
        positiveVotes.adjustsFontForContentSizeCategory = false
        negativeVotes.adjustsFontForContentSizeCategory = false
    }
}
