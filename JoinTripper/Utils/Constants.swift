//
//  Constants.swift
//  JoinTripper
//
//  Created by Dario Corral on 12/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation

import Foundation

//MARK: - Constants struct
struct Constants {
    
    struct Segue {
        
        static let showAirportsDeparture = "showAirportsDeparture"
        static let showAirportsArrival = "showAirportsArrival"
        static let toPassengers = "toPassengers"
        static let toFlightsPool = "toFlightsPool"
        static let toFlightsDetail = "toFlightsDetail"
        static let toGateWebsite = "toGateWebsite"
        static let toCreateProfile = "toCreateProfile"
        static let showCountries = "showCountries"
        static let showLanguages = "showLanguages"
        static let toExRequestMain = "toExRequestMain"
        static let toSearchFlight = "toSearchFlight"
        static let toMatchExRequest = "toMatchExRequest"
        static let toMatchProfile = "toMatchProfile"
        static let toModifyProfile = "toModifyProfile"
    }
    
    struct UserDefaults {
        static let currentUser = "currentUser"
        static let uid = "uid"
        static let username = "username"
    }
    
}
