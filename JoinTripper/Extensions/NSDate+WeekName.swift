//
//  NSDate+WeekName.swift
//  JoinTripper
//
//  Created by Dario Corral on 07/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation

extension Date {
    
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return (formatter.string(from: self as Date))
    }
    
}
