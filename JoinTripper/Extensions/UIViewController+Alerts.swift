//
//  UIViewController+Alerts.swift
//  JoinTripper
//
//  Created by Dario Corral on 03/11/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, description: String) {
        //Alert config
        let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
