//
//  UIButton+Animation.swift
//  JoinTripper
//
//  Created by Dario Corral on 03/11/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func shakeAnimationButton(for button: UIButton){
        let bounds = button.bounds
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
            button.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
        }, completion: nil)
        button.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
        
    }

}
