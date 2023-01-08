//
//  ProfileViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 14/01/2019.
//  Copyright © 2019 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftSpinner

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var countryField: UILabel!
    @IBOutlet weak var ageField: UILabel!
    @IBOutlet weak var genderField: UILabel!
    @IBOutlet weak var positiveVotesField: UILabel!
    @IBOutlet weak var negativeVotesField: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var languagesField: UILabel!
    
    
    //MARK: - Get Date Of birth User info
    var dateOfBirth = String()
    
    func getDateOfBirth() {
        guard let firUser = Auth.auth().currentUser else {return}
        
        UserService.fetchUserFields(for: firUser, completion: { (userProfile) in
            guard let dateOfBirthString = userProfile?.dateOfBirth else {return}
            self.dateOfBirth = dateOfBirthString
            
        })
    }
    
    //Var for languages
    var languages: String?
    
    //MARK: - Function to fill up Profile user
    func fillUpProfile () -> Void {
        
        SwiftSpinner.show("Loading Profile")
        SwiftSpinner.show(delay: 3.0, title: "Low Connectivity...")
        
        //Remove languages
        self.languages? = ""
        
        let loading = DispatchGroup()
        
        guard let firUser = Auth.auth().currentUser else {return}
        
        UserService.fetchUserFields(for: firUser, completion: { (userProfile) in
            
            loading.enter()
            
            guard let userProfile = userProfile else {
                print("Error during userProfile")
                return}
            
            //Date of birth conversion to age
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMyyyy"
            
            if userProfile.dateOfBirth == "--" {
                
                self.ageField.text = "+18 years"
                
            } else {
                
                guard let date = dateFormatter.date(from: userProfile.dateOfBirth) else {return}
                let dcf = DateComponentsFormatter()
                dcf.allowedUnits = .year
                dcf.unitsStyle = .full
                dcf.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                guard let age = dcf.string(from: date, to: Date()) else {return}
                
                self.ageField.text = "\(age.prefix(2)) years"
                
            }
            
            self.username.text = userProfile.username
            self.countryField.text = userProfile.country
            self.genderField.text = userProfile.gender
            
            //Assign languages values to global var
            self.languages = userProfile.languages
            
            //Prepare first 3 characters languages
            let languagesComp = userProfile.languages.components(separatedBy: ",")
            var languagesArray: [String] = []
            
            for item in languagesComp {
                languagesArray.append(String(item.prefix(3)))
            }
            
            let languagesString = languagesArray.joined(separator: ",")
            
            self.languagesField.text = languagesString
            
            UserService.votesForUserCount(firUser.uid, positiveVotes: true) { (votes) in
                self.positiveVotesField.text = "\(votes)"
            }
            
            UserService.votesForUserCount(firUser.uid, positiveVotes: false) { (votes) in
                self.negativeVotesField.text = "\(votes)"
            }
            
            //Load and present image profile
            // Reference to an image file in Firebase Storage
            let imageName = firUser.uid + ".jpg"
            let imageRef = Storage.storage().reference().child(imageName)
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading profile image: \(error)")
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    self.profileImageView.image = image
                    loading.leave()
                    
                    loading.notify(queue: .main) {
                        SwiftSpinner.hide()
                    }
                }
            }
            
        })
        
    }
    
    //MARK - Reload Exchange Request after background state
    @objc func reloadViewController() {
        
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
        
            //Initial Load for images loading issues
            self.fillUpProfile ()
            
            //Get Date Of Birth Value
            self.getDateOfBirth()
            
            //Adjust Label text size
            self.username.adjustsFontForContentSizeCategory = true
            self.username.adjustsFontSizeToFitWidth = true
            let usernameHeight = username.optimalHeight
            username.frame = CGRect(x: username.frame.origin.x, y: username.frame.origin.y, width: username.frame.width, height: usernameHeight)
            
            self.countryField.adjustsFontForContentSizeCategory = true
            self.countryField.adjustsFontSizeToFitWidth = true
            let countryFieldHeight = countryField.optimalHeight
            countryField.frame = CGRect(x: countryField.frame.origin.x, y: countryField.frame.origin.y, width: countryField.frame.width, height: countryFieldHeight)
            
            self.ageField.adjustsFontForContentSizeCategory = true
            self.ageField.adjustsFontSizeToFitWidth = true
            let ageFieldHeight = ageField.optimalHeight
            ageField.frame = CGRect(x: ageField.frame.origin.x, y: ageField.frame.origin.y, width: ageField.frame.width, height: ageFieldHeight)
            
            self.genderField.adjustsFontForContentSizeCategory = true
            self.genderField.adjustsFontSizeToFitWidth = true
            let genderFieldHeight = genderField.optimalHeight
            genderField.frame = CGRect(x: genderField.frame.origin.x, y: genderField.frame.origin.y, width: genderField.frame.width, height: genderFieldHeight)
            
            self.positiveVotesField.adjustsFontForContentSizeCategory = true
            self.positiveVotesField.adjustsFontSizeToFitWidth = true
            let positiveVotesFieldHeight = positiveVotesField.optimalHeight
            positiveVotesField.frame = CGRect(x: positiveVotesField.frame.origin.x, y: positiveVotesField.frame.origin.y, width: positiveVotesField.frame.width, height: positiveVotesFieldHeight)
            
            self.negativeVotesField.adjustsFontForContentSizeCategory = true
            self.negativeVotesField.adjustsFontSizeToFitWidth = true
            let negativeVotesFieldHeight = negativeVotesField.optimalHeight
            negativeVotesField.frame = CGRect(x: negativeVotesField.frame.origin.x, y: negativeVotesField.frame.origin.y, width: negativeVotesField.frame.width, height: negativeVotesFieldHeight)
            
            self.languagesField.adjustsFontForContentSizeCategory = true
            self.languagesField.adjustsFontSizeToFitWidth = true
            let languagesLabelHeight = languagesField.optimalHeight
            languagesField.frame = CGRect(x: languagesField.frame.origin.x, y: languagesField.frame.origin.y, width: languagesField.frame.width, height: languagesLabelHeight)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        //Check internet Connection
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Verify your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
        
            self.fillUpProfile()
            self.getDateOfBirth()
        }
        
    }
    
    //Function to log out
    @IBAction func logOutTappedButton (sender: UIButton){
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
    
    //MARK: - Prepare data to pass to Modify Profile Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let username = self.username.text,
            let country = self.countryField.text,
            let gender = self.genderField.text,
            let languages = self.languages else {return}
        
        //Call MatchViewController
        let modifyProfileViewController = segue.destination as! ModifyProfileViewController
        
        modifyProfileViewController.username = username
        modifyProfileViewController.country = country
        modifyProfileViewController.dateOfBirth = self.dateOfBirth
        modifyProfileViewController.gender = gender
        modifyProfileViewController.languages = languages
    }
    
    @IBAction func modifyTappedButton (sender: UIButton){
        self.performSegue(withIdentifier: Constants.Segue.toModifyProfile, sender: self)
    }
}
