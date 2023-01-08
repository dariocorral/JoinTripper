//
//  Storyboard+Utility.swift
//  JoinTripper
//
//  Created by Dario Corral on 15/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

//MARK: - UIStoryboard enum and function
extension UIStoryboard {
    
    enum MCType: String {
        
        case main
        case login
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(type: MCType, bundle: Bundle? = nil) {
        self.init(name: type.filename, bundle: bundle)
    }
    
    static func initialViewController(for type: MCType) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        guard let initialViewController = storyboard.instantiateInitialViewController() else {
            fatalError("Couldn't instantiate initial view controller for \(type.filename) storyboard.")
        }
        
        return initialViewController
    }
    
    static func loadViewController(for type:MCType, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(type: type)
        let loadViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        
        
        return loadViewController
    }
}

