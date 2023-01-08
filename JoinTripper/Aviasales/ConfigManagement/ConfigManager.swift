//
//  ConfigManager.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation

@objcMembers
class ConfigManager: NSObject {
    
    static let shared = ConfigManager()
    
    let provider = ConfigProvider()
    
    lazy var config: Config? = self.provider.obtainConfig()
    
    lazy var partnerMarker: String = self.config?.partnerMarker ?? String()
    lazy var apiToken: String = self.config?.apiToken ?? String()
    lazy var appodealKey: String = self.config?.appodealKey ?? String()
    lazy var aviasalesAds: Bool =  self.config?.aviasalesAds ?? true
    lazy var flightsEnabled: Bool = self.config?.flightsEnabled ?? true
    lazy var hotelsEnabled: Bool = self.config?.hotelsEnabled ?? true
    lazy var appLogo: String? = self.config?.appLogo
    lazy var appName: String? = self.localized(self.config?.appNames)
    lazy var appDescription: String? = self.localized(self.config?.appDescriptions)
    lazy var feedbackEmail: String = self.config?.feedbackEmail ?? String()
    lazy var itunesLink: String = self.config?.itunesLink ?? String()
    lazy var externalLinks: [ExternalLink]? = self.localized(self.config?.externalLinks)
    lazy var colorParams: ColorParams? = self.config?.colorParams
    lazy var defaultCurrency: String? = self.config?.searchParams?.defaultCurrency
    lazy var flightsOrigin: String? = self.config?.searchParams?.flightsOrigin
    lazy var flightsDestination: String? = self.config?.searchParams?.flightsDestination
    lazy var hotelsCityID: String? = self.config?.searchParams?.hotelsCity?.identifier
    lazy var hotelsCityName: String? = self.localized(self.config?.searchParams?.hotelsCity?.names)
    lazy var defaultLocale: String = self.config?.defaultLocale ?? "en"
}

private extension ConfigManager {
    
    func localized<Value>(_ values: [String : Value]?) -> Value? {
        guard let values = values else {
            return nil
        }
        let locale = Locale.current.languageCode ?? defaultLocale
        return values[locale] ?? values[defaultLocale]
    }
}
