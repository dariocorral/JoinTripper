//
//  LoginViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 15/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase


//In order to avoid namespace conflict with Xcode User
typealias FIRUser = FirebaseAuth.User


class LoginViewController : UIViewController {
    
    
    @IBOutlet weak var logginButton: UIButton!
    
    //Animation stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logginButton.alpha = 0.0
        
    }
    
    //Adapt text login button
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logginButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.logginButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Check internet Connection
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        //Animation
        UIView.animate(withDuration: 2, delay: 2, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.logginButton.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if currentReachabilityStatus != .notReachable {
            // Access the FUIAuth default auth UI singleton
            guard let authUI = FUIAuth.defaultAuthUI()
                else { return }
            
            // Set FUIAuth's singleton delegate
            authUI.delegate = self
            
            // configure Auth UI for Facebook login
            let providers: [FUIAuthProvider] = [FUIGoogleAuth(),FUIFacebookAuth()]
            authUI.providers = providers
            
            
            // Present the FirebaseLogin view controller
            let authViewController = FirebaseLoginViewController(authUI: authUI)
            let navc = UINavigationController(rootViewController: authViewController)
            self.present(navc, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: FUIAuthDelegate {
    
    //Set alert to guide user along verification process
    func alertEmailChecking() {
        
        //Set alert to confirm email till it's confirmed by user
        let alertVC = UIAlertController(title: "Verify your email", message: "Your email address: \(Auth.auth().currentUser?.email ?? "Email not found") must be confirmed. Please check your email inbox and press Check Verification button afterwards", preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Check verification", style: .default){
            (_) in
            
            guard let currentUser = Auth.auth().currentUser  else{ return}
            
            //Reload user profile to check
            currentUser.reload(completion: { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                } else {
                    
                    if currentUser.isEmailVerified{
                        print("Email verified")
                        self.performSegue(withIdentifier: Constants.Segue.toCreateProfile, sender: self)
                    } else {
                        currentUser.delete {error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("Account deleted")
                            }
                        }
                        
                        let alertNotVerified = UIAlertController(title: "Error", message: "Email account not verified. Process Cancelled", preferredStyle: .alert)
                        alertNotVerified.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alertNotVerified, animated: true, completion: nil)
                        
                        //Back to login Menu
                        let initialViewController = UIStoryboard.initialViewController(for: .login)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                        
                        return }
                }
                
            })
        })
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default) {
            (_) in
            
            //Delete account
            Auth.auth().currentUser?.delete {error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Account deleted")
                }
            }
            
            //Back to login Menu
            let initialViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            
            return
        }
        
        //Check FIRUser returned is not nil
        guard let user = user
            else {return}
        
        //Call UserService.swift show function
        UserService.show(forUID: user.uid, completion: {(user) in
            
            if let user = user {
                
                //Singleton pattern - User.swift
                try! User.setCurrent(user, writeToUserDefaults: true)
                
                //Use Storyboard+Utility.swift logic (extensions)
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.view.window?.rootViewController = initialViewController
                self.view.window?.makeKeyAndVisible()
                
            } else {
                
                //Check what is provider data
                if let providerData = Auth.auth().currentUser?.providerData {
                    for userInfo in providerData {
                        switch userInfo.providerID {
                            
                        case "password":
                            print("user is signed in with mail")
                            
                            //Verification email sending
                            print(Auth.auth().currentUser?.email ?? "no email")
                            Auth.auth().currentUser?.sendEmailVerification {(error) in
                                if let error = error {
                                    assertionFailure(error.localizedDescription)
                                    
                                    return
                                }
                            }
                            
                            //Alert Controller to handle next movements
                            self.alertEmailChecking()
                            
                        default:
                            print("user is signed in with \(userInfo.providerID)")
                        }
                    }
                }
                
                self.performSegue(withIdentifier: Constants.Segue.toCreateProfile, sender: self)
            }
        })
    }
}



