//
//  FirebaseLoginViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseUI

class FirebaseLoginViewController: FUIAuthPickerViewController {
    
    override init(nibName: String?, bundle: Bundle?, authUI: FUIAuth) {
        super.init(nibName: "FUIAuthPickerViewController", bundle: bundle, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = ColorHex.hexStringToUIColor(hex: "#B68CE1")
        
        let imageName = "Logo"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        let screenSize: CGRect = UIScreen.main.bounds
        let midY = screenSize.midY - ((screenSize.height * 0.35) / 1)
        let midX =  screenSize.midX - ((screenSize.height * 0.25) / 2)
        
        imageView.frame = CGRect(x: midX, y: midY, width: screenSize.height * 0.25, height: screenSize.height * 0.25)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        self.view.addSubview(imageView)
        
    }
    
}

