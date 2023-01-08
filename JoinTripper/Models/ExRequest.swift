//
//  ExRequest.swift
//  JoinTripper
//
//  Created by Dario Corral on 29/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class ExRequest {
    
    let key: String
    let date: String
    let flight: String
    let airport: String
    let airline: String
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let date = dict["date"] as? String,
            let flight = dict["flight"] as? String,
            let airport = dict["airport"] as? String,
            let airline = dict["airline"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.date = date
        self.flight = flight
        self.airport = airport
        self.airline = airline
        
    }
    
}


