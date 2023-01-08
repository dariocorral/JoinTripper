//
//  AppConfigurator.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation
import AviasalesSDK

@objcMembers
class AppConfigurator: NSObject {
    
    static func configure() {
        configureAviasalesSDK()
        //configureAdvertisementManager()
    }
}

private extension AppConfigurator {
    
    static func configureAviasalesSDK() {
        
        let token = ConfigManager.shared.apiToken
        let marker = ConfigManager.shared.partnerMarker
        let locale = Locale.current.identifier
        
        let configuration = AviasalesSDKInitialConfiguration(apiToken: token, apiLocale: locale, partnerMarker: marker)
        
        AviasalesSDK.setup(with: configuration)
    }
    
//    static func configureAdvertisementManager() {
//
//        if !ConfigManager.shared.appodealKey.isEmpty {
//            JRAdvertisementManager.sharedInstance().initializeAppodeal(withAPIKey: ConfigManager.shared.appodealKey, testingEnabled: true)
//        }
//    }
}

