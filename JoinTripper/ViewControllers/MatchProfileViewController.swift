//
//  MatchProfileViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 30/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
//import FirebaseStorageUI
import MessageUI
import SwiftSpinner


class MatchProfileViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate{
    
    //Message/email composer instance
    let messageComposer = MessageComposer()
    let emailComposer = EmailComposer()
    
    //Variables fetched from MatchViewController
    var age = String ()
    var gender = String ()
    var username = String ()
    var country = String ()
    var uid = String()
    var email = String()
    var languages = String()
    var exRequestId = String()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var positiveVotesLabel: UILabel!
    @IBOutlet weak var negativesVotesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
        
            fullfilProfile()
            
            //Adjust Label text size
            self.usernameLabel.adjustsFontForContentSizeCategory = true
            self.usernameLabel.adjustsFontSizeToFitWidth = true
            let usernameLabelHeight = usernameLabel.optimalHeight
            usernameLabel.frame = CGRect(x: usernameLabel.frame.origin.x, y: usernameLabel.frame.origin.y, width: usernameLabel.frame.width, height: usernameLabelHeight)
            
            self.countryLabel.adjustsFontForContentSizeCategory = true
            self.countryLabel.adjustsFontSizeToFitWidth = true
            let countryLabelHeight = countryLabel.optimalHeight
            countryLabel.frame = CGRect(x: countryLabel.frame.origin.x, y: countryLabel.frame.origin.y, width: countryLabel.frame.width, height: countryLabelHeight)
            
            self.ageLabel.adjustsFontForContentSizeCategory = true
            self.ageLabel.adjustsFontSizeToFitWidth = true
            let ageLabelHeight = ageLabel.optimalHeight
            ageLabel.frame = CGRect(x: ageLabel.frame.origin.x, y: ageLabel.frame.origin.y, width: ageLabel.frame.width, height: ageLabelHeight)
            
            self.genderLabel.adjustsFontForContentSizeCategory = true
            self.genderLabel.adjustsFontSizeToFitWidth = true
            let genderLabelHeight = genderLabel.optimalHeight
            genderLabel.frame = CGRect(x: genderLabel.frame.origin.x, y: genderLabel.frame.origin.y, width: genderLabel.frame.width, height: genderLabelHeight)
            
            self.positiveVotesLabel.adjustsFontForContentSizeCategory = true
            self.positiveVotesLabel.adjustsFontSizeToFitWidth = true
            let positiveVotesLabelHeight = positiveVotesLabel.optimalHeight
            positiveVotesLabel.frame = CGRect(x: positiveVotesLabel.frame.origin.x, y: positiveVotesLabel.frame.origin.y, width: positiveVotesLabel.frame.width, height: positiveVotesLabelHeight)
            
            self.negativesVotesLabel.adjustsFontForContentSizeCategory = true
            self.negativesVotesLabel.adjustsFontSizeToFitWidth = true
            let negativesVotesLabelHeight = negativesVotesLabel.optimalHeight
            negativesVotesLabel.frame = CGRect(x: negativesVotesLabel.frame.origin.x, y: negativesVotesLabel.frame.origin.y, width: negativesVotesLabel.frame.width, height: negativesVotesLabelHeight)
            
            self.languagesLabel.adjustsFontForContentSizeCategory = true
            self.languagesLabel.adjustsFontSizeToFitWidth = true
            let languagesLabelHeight = languagesLabel.optimalHeight
            languagesLabel.frame = CGRect(x: languagesLabel.frame.origin.x, y: languagesLabel.frame.origin.y, width: languagesLabel.frame.width, height: languagesLabelHeight)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Check internet Connection
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        //Call Votes user
        UserService.votesForUserCount(self.uid, positiveVotes: true) { (votes) in
            self.positiveVotesLabel.text = "\(votes)"
        }
        UserService.votesForUserCount(self.uid, positiveVotes: false) { (votes) in
            self.negativesVotesLabel.text = "\(votes)"
        }
        
    }
    
    func fullfilProfile() {
        
        SwiftSpinner.show("Loading Profile")
        SwiftSpinner.show(delay: 3.0, title: "Low Connectivity...")
        let loading = DispatchGroup()
        
        loading.enter()
        
        self.usernameLabel.text = username
        self.countryLabel.text = country
        self.ageLabel.text = age + " years"
        self.genderLabel.text = gender
        
        //Prepare first 3 characters languages
        let languagesComp = languages.components(separatedBy: ",")
        var languagesArray: [String] = []
        
        for item in languagesComp {
            languagesArray.append(String(item.prefix(3)))
        }
        
        let languagesString = languagesArray.joined(separator: ",")
        
        self.languagesLabel.text = languagesString
        
        //Call Votes user
        UserService.votesForUserCount(self.uid, positiveVotes: true) { (votes) in
            self.positiveVotesLabel.text = "\(votes)"
        }
        UserService.votesForUserCount(self.uid, positiveVotes: false) { (votes) in
            self.negativesVotesLabel.text = "\(votes)"
        }
        
        //Load and present image profile
        // Reference to an image file in Firebase Storage
        let imageRef = Storage.storage().reference().child(self.uid + ".jpg")
        
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
    }
    
    
    @IBAction func vote (_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Vote", message: "Select Your Vote", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title:"😃", style: UIAlertAction.Style.default) { (_) in self.votePositive()
        })
        
        alert.addAction(UIAlertAction(title: "☹️", style: UIAlertAction.Style.default) { (_) in self.voteNegative()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func votePositive() {
        
        let loading = DispatchGroup()
        loading.enter()
        
        guard let firUser = Auth.auth().currentUser else {return}
        
        UserService.voteUser(firUser, usertToVote: self.uid, positiveVote: true) { (vote) in
            guard vote != nil else {
                
                let alert = UIAlertController(title: "User already has been voted", message: "Only it is possible one vote for each user", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            loading.leave()
            
            loading.notify(queue: .main) {
                UserService.votesForUserCount(self.uid, positiveVotes: true) { (votes) in
                    self.positiveVotesLabel.text = "\(votes)"
                }
            }
            
            let alert = UIAlertController(title: "Done", message: "You vote has been cast", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil )
        }
        
    }
    
    func voteNegative() {
        
        let loading = DispatchGroup()
        loading.enter()
        
        guard let firUser = Auth.auth().currentUser else {return}
        
        UserService.voteUser(firUser, usertToVote: self.uid, positiveVote: false) { (vote) in
            guard vote != nil else {
                
                let alert = UIAlertController(title: "User already has been voted", message: "Only it is possible one vote for each user", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            loading.leave()
            
            loading.notify(queue: .main) {
                UserService.votesForUserCount(self.uid, positiveVotes: false) { (votes) in
                    self.negativesVotesLabel.text = "\(votes)"
                }
            }
            
            let alert = UIAlertController(title: "Done", message: "You vote has been cast", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        
        let loading = DispatchGroup()
        
        //Fetch data for iMessage
        let dividedExRequestInv = self.exRequestId.components(separatedBy: ",")
        let date = dividedExRequestInv[0]
        let flight = dividedExRequestInv[1]
        
        
        var dateExRequest = String()
        
        //Dataformatter conversion
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        if let dateF = dateFormatter.date(from: date){
            let dateFormatterAlt = DateFormatter()
            dateFormatterAlt.locale = Locale(identifier: "en")
            dateFormatterAlt.timeZone = TimeZone.current
            dateFormatterAlt.dateStyle = .long
            dateExRequest = dateFormatterAlt.string(from: dateF)
        } else
        { dateExRequest = date}
        
        let defaultMessage = "Hi \(self.username) from JoinTripper. Both of us we'll get the flight \(flight) next \(dateExRequest). Let's talk about..."
        
        //Set alert to confirm email till it's confirmed by user
        let alertVC = UIAlertController(title: "Message type", message: "Choose your message method", preferredStyle: .alert)
        
        
        alertVC.addAction(UIAlertAction(title: "iMessage", style: .default){
            (_) in
            
            SwiftSpinner.show("Loading iMessage")
            SwiftSpinner.show(delay: 3.0, title: "Low Connectivity...")
            loading.enter()
            
            if (self.messageComposer.canSendText()) {
                
                let messageComposeVC = self.messageComposer.configureMessageComposeViewController(email: "\(self.email)", body: defaultMessage)
                
                self.present(messageComposeVC, animated: true, completion: nil)
                
                loading.leave()
                
                loading.notify(queue: .main) {
                    SwiftSpinner.hide()
                }
                
            } else {
                
                // Let the user know if his/her device isn't able to send text messages
                let alert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                loading.leave()
                
                loading.notify(queue: .main) {
                    SwiftSpinner.hide()
                }
                
            }
        })
        
        alertVC.addAction(UIAlertAction(title: "eMail", style: .default) {
            (_) in
            
            SwiftSpinner.show("Loading eMail")
            SwiftSpinner.show(delay: 3.0, title: "Low Connectivity...")
            loading.enter()
            
            if self.emailComposer.canSendEmail() {
                
                let emailComposerVC = self.emailComposer.configuredMailComposeViewController(email: "\(self.email)", body: "<p>\(defaultMessage)</p>")
                
                self.present(emailComposerVC, animated: true, completion: nil)
                
                loading.leave()
                
                loading.notify(queue: .main) {
                    SwiftSpinner.hide()
                }
                
            } else {
                
                // Let the user know if his/her device isn't able to send text messages
                let alert = UIAlertController(title: "Cannot Send Email", message: "Your device is not able to send Emails.", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                loading.leave()
                
                loading.notify(queue: .main) {
                    SwiftSpinner.hide()
                }
            }
            
        })
        
        alertVC.addAction(UIAlertAction(title: "cancel", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
