//
//  SecurityCheckpointViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 26/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import TJBioAuthentication
import FirebaseAuth



class SecurityCheckpointViewController: UIViewController {
    
    //MARK: - Call ViewDidAppear to show checkpoint security
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//       self.securityCheckPoint()
        
    }
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    //MARK: - Authenticate FaceId / Biometrics / Password
    func securityCheckPoint() {
        print("Loading security check point")
        TJBioAuthenticator.shared.authenticateUserWithBioMetrics(success: {
            // Biometric Authentication success
            //Segue
            self.performSegue(withIdentifier: Constants.Segue.toExRequestMain, sender: self)
            
        }) { (error) in
            // Biometric Authentication unsuccessful
            
            print("Error Authentication: \(error)")
            switch error{
                
            case .userCancel:
                
                guard Auth.auth().currentUser != nil else {
                    return
                }
                do {
                    try Auth.auth().signOut()
                    
                    //Use Storyboard+Utility.swift logic (extensions)
                    let initialViewController = UIStoryboard.initialViewController(for: .login)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                    
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            
                
            default:
                self.executePasscodeAuthentication()
            }
        }
    }
    func executePasscodeAuthentication(){
        TJBioAuthenticator.shared.authenticateUserWithPasscode(success: {
            
            if self.currentReachabilityStatus == .notReachable {
                let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                do {
                    try Auth.auth().signOut()
                    
                    //Use Storyboard+Utility.swift logic (extensions)
                    let initialViewController = UIStoryboard.initialViewController(for: .login)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                    
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            } else {
            //Segue
            self.performSegue(withIdentifier: Constants.Segue.toExRequestMain, sender: self)
            }
            
            
        }) { (error) in
            
            
//            self.showAlert(title: "Error", description: error.getMessage())
            guard Auth.auth().currentUser != nil else {
                return
            }
            do {
                try Auth.auth().signOut()
                
                //Use Storyboard+Utility.swift logic (extensions)
                let initialViewController = UIStoryboard.initialViewController(for: .login)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
                
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
}

