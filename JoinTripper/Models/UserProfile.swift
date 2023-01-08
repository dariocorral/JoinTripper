//
//  UserProfile.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class UserProfile {
    
    let username: String
    let country: String
    let gender : String
    let dateOfBirth: String
    let currency: String
    let key: String
    let email: String
    let token: String
    let languages: String
    
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let country = dict["country"] as? String,
            let gender = dict["gender"] as? String,
            let dateOfBirth = dict["dateOfBirth"] as? String,
            let currency = dict["currency"] as? String,
            let email = dict["email"] as? String,
            let token = dict["token"] as? String,
            let languages = dict["languages"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.country = country
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.username = username
        self.currency = currency
        self.email = email
        self.token = token
        self.languages = languages
    }
}
