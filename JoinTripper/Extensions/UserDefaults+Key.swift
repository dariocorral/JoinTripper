//
//  UserDefaults+Key.swift
//  JoinTripper
//
//  Created by Dario Corral on 09/03/2019.
//  Copyright © 2019 Dario Corral. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case lastReviewRequestAppVersion
    }
    
    func integer(forKey key: Key) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }
    
    func set(_ integer: Int, forKey key: Key) {
        set(integer, forKey: key.rawValue)
    }
    
    func set(_ object: Any?, forKey key: Key) {
        set(object, forKey: key.rawValue)
    }
}
