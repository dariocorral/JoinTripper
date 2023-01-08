//
//  Config.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import ObjectMapper

struct Config: Mappable {
    
    var partnerMarker: String?
    var apiToken: String?
    var appodealKey: String?
    var aviasalesAds: Bool?
    var flightsEnabled: Bool?
    var hotelsEnabled: Bool?
    var appLogo: String?
    var appNames: [String : String]?
    var appDescriptions: [String : String]?
    var feedbackEmail: String?
    var itunesLink: String?
    var externalLinks: [String : [ExternalLink]]?
    var colorParams: ColorParams?
    var searchParams: SearchParams?
    var defaultLocale: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        partnerMarker <- map["partner_marker"]
        apiToken <- map["api_token"]
        appodealKey <- map["appodeal_key"]
        aviasalesAds <- map["aviasales_ads"]
        flightsEnabled <- map["flights_enabled"]
        hotelsEnabled <- map["hotels_enabled"]
        appLogo <- map["app_logo"]
        appNames <- map["app_name"]
        appDescriptions <- map["app_description"]
        feedbackEmail <- map["feedback_email"]
        itunesLink <- map["itunes_link"]
        externalLinks <- map["external_links"]
        colorParams <- map["color_params"]
        searchParams <- map["search_params"]
        defaultLocale <- map["default_locale"]
    }
}

struct ExternalLink: Mappable {
    
    var url: String?
    var name: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        url <- map["url"]
    }
}

struct ColorParams: Mappable {
    
    var mainColor: String?
    var actionColor: String?
    var formTintColor: String?
    var formBackgroundColor: String?
    var formTextColor: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        mainColor <- map["main_color"]
        actionColor <- map["action_color"]
        formTintColor <- map["form_tint_color"]
        formBackgroundColor <- map["form_background_color"]
        formTextColor <- map["form_text_color"]
    }
}

struct SearchParams: Mappable {
    
    var defaultCurrency: String?
    var flightsOrigin: String?
    var flightsDestination: String?
    var hotelsCity: SearchCity?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        defaultCurrency <- map["default_currency"]
        flightsOrigin <- map["flights_origin"]
        flightsDestination <- map["flights_destination"]
        hotelsCity <- map["hotels_city"]
    }
}

struct SearchCity: Mappable {
    
    var identifier: String?
    var names: [String : String]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        identifier <- map["id"]
        names <- map["names"]
    }
}

