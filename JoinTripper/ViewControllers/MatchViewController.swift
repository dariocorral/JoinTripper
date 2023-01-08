//
//  MatchViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 30/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseAuth.FIRUser
import FirebaseDatabase
import CoreData
import SwiftSpinner

class MatchViewController: UITableViewController {
    
    //Variable coming from Exchange View Controller
    var usersProfile = [UserProfile]()
    var exRequestId = String()
    
    func do_table_refresh()
    {
        self.tableView.reloadData()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorStyle = .singleLine
        SwiftSpinner.hide()
    }
    
    func updateProfilesToShow () -> Void {
        
        SwiftSpinner.show("Loading Match Profiles")
        SwiftSpinner.show(delay: 3.0, title: "Low Connectivity...")
        
        print("ExRequest to search: \(exRequestId)")
        usersProfile.removeAll()
        self.tableView.reloadData()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.separatorStyle = .none
        
        UserService.fetchUsersUidsFromExRequest(exRequest: exRequestId, completion:{ (uids) in
            
            for uid in uids {
                Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with:{ (snapshot) in
                    guard let userProfile = UserProfile.init(snapshot: snapshot ) else {
                        print("Error during userProfile loading")
                        return }
                    
                    self.usersProfile.append(userProfile)
                    DispatchQueue.main.async(execute: {self.do_table_refresh()})
                })
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        
        //Check internet Connection
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        self.updateProfilesToShow()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        //Gradient Background color for tableView
        self.setTableViewBackgroundGradient(sender: self, ColorHex.hexStringToUIColor(hex: "#F2B2AF"), ColorHex.hexStringToUIColor(hex: "#B68CE1"))
        
        // Get the height of the status bar and set cell height automatically
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 125
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersProfile.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userProfile = usersProfile[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchExRequestCell", for: indexPath) as! MatchExRequestCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        let username =  userProfile.username
        let gender = userProfile.gender
        let country = userProfile.country
        let dateOfBirth = userProfile.dateOfBirth
        let uid = userProfile.key
        
        //Date of birth conversion to age
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.timeZone = TimeZone.current
        
        if  let date = dateFormatter.date(from: dateOfBirth) {
            
            let dcf = DateComponentsFormatter()
            dcf.allowedUnits = .year
            dcf.unitsStyle = .full
            dcf.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let age = dcf.string(from: date, to: Date())
            
            cell.age.text = "\(age?.prefix(2) ?? "") years"
        } else {
            cell.age.text = "+18 years"
        }
        
        
        cell.country.text = country
        cell.username.text = username
        cell.gender.text = gender
        
        UserService.votesForUserCount(uid, positiveVotes: true) { (votes) in
            cell.positiveVotes.text = "\(votes)"
        }
        UserService.votesForUserCount(uid, positiveVotes: false) { (votes) in
            cell.negativeVotes.text = "\(votes)"
        }
        
        return cell
        
    }
    
    //MARK: - Move Match Exchange Request
    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        // Get reference to object being moved so you can reinsert it
        let movedItem = usersProfile[fromIndex]
        
        // Remove item from array
        usersProfile.remove(at: fromIndex)
        
        // Insert item in array at new location
        usersProfile.insert(movedItem, at: toIndex)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // Update the model
        self.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    //MARK: - Delete Match Exchange Requests
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            usersProfile.remove(at: indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    //MARK: - Refresh table view
    @IBAction func refreshTable(_ sender: UIButton) {
        
        self.updateProfilesToShow()
        
    }
    
    //MARK: - Prepare data to pass to Match Profile Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.toMatchProfile {
            
            //Figure out which indexpath was taped
            if let indexpath = self.tableView.indexPathForSelectedRow {
                
                let userProfile = self.usersProfile[indexpath.row]
                
                let username =  userProfile.username
                let gender = userProfile.gender
                let country = userProfile.country
                let dateOfBirth = userProfile.dateOfBirth
                let uid = userProfile.key
                let email = userProfile.email
                let languages = userProfile.languages
                
                //Call MatchViewController
                let matchProfileViewController = segue.destination as! MatchProfileViewController
                
                //Age calculation
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "ddMMyyyy"
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.locale = Locale(identifier: "en")
                
                //Age variable when is not filled
                if  let date = dateFormatter.date(from: dateOfBirth) {
                    let dcf = DateComponentsFormatter()
                    dcf.allowedUnits = .year
                    dcf.unitsStyle = .full
                    dcf.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let age = dcf.string(from: date, to: Date())
                    
                    matchProfileViewController.age = "\(age?.prefix(2) ?? "")"
                    
                    
                } else {
                    
                    matchProfileViewController.age = "+18"
                }
                
                //Define variables in MatchViewController
                matchProfileViewController.username = username
                matchProfileViewController.country = country
                matchProfileViewController.gender = gender
                matchProfileViewController.uid = uid
                matchProfileViewController.email = email
                matchProfileViewController.languages = languages
                matchProfileViewController.exRequestId = self.exRequestId
            }
        }
    }
    
    //MARK: - Perform segue when row tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: Constants.Segue.toMatchProfile, sender: self)
        
    }
    
}

