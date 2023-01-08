//
//  AppStoreReviewHelper.swift
//  JoinTripper
//
//  Created by Dario Corral on 09/03/2019.
//  Copyright © 2019 Dario Corral. All rights reserved.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
    
    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main
        
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)
        
        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }
        
        SKStoreReviewController.requestReview()
        
        defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
    }
}
