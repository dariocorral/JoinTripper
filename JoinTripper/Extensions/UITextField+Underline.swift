//
//  UITextField+Underline.swift
//  JoinTripper
//
//  Created by Dario Corral on 09/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

extension UITextField {
    
    func underlined(){
        
        var bottomBorder = UIView()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBorder = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.backgroundColor = ColorHex.hexStringToUIColor(hex: "#C4C4C4") // Set Border-Color
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomBorder)
        
        bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true // Set Border-Strength

    }
}
