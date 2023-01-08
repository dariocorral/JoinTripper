//
//  ExchangeRequestsViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 26/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import CoreData
import SwiftSpinner
import CircleLabel
import CoreLocation
import TJBioAuthentication


//MARK: - Protocol used for sending countries data back
protocol ExchangeRequestsViewReload: class {
    func reloadData()
}

class ExchangeRequestsViewController: UITableViewController, ExchangeRequestsViewReload, CLLocationManagerDelegate{
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    //Full Screen View
    var overlayView: UIView!
    
    //Var to control Pop Alert Ex Req = 0
    var exReqCountCheck = 0
    
    
    var reloadDataTimer: Timer?

    //Buttons
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    var tabBar: UITabBar?
    
    //Core data airports
    let dataAirports = DataAPI()
    var airports: [NSManagedObject] = []
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to show you the closest Airports we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
     func reloadData() {
        
        //Check internet Connection
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
        
            self.exchangeRequests?.removeAll()
            self.tableView.reloadData()
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tabBar?.invalidateIntrinsicContentSize()
    }
    
    //Attribute ExRequest
    var exchangeRequests: [ExRequest]?

    //Attributes Firebase database connection
    var hasConnected: Bool = false
    var isConnected = Bool()
    
    //Attributes Row Edit action
    var indexPathToModifyExReq = IndexPath()
    
    func checkProfileCompleted(){
        //Check FIRUser returned is not nil
        guard let currentUser = Auth.auth().currentUser  else{ return}
        
        UserService.username(currentUser, completion: {(username) in
            let username = username
            
            if username == nil {
                //Display Alert Profile not completed
                let alert = UIAlertController(title: "Profile not completed", message: "You should complete your profile and accept our Terms & Privacy policy", preferredStyle: UIAlertController.Style.alert)
                
                let action: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                    do {
                        try Auth.auth().signOut()
                        //Use Storyboard+Utility.swift logic (extensions)
                        let initialViewController = UIStoryboard.initialViewController(for: .login)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    //MARK: - Call ViewDidAppear to show control profile and Preload Airports data
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.async{
            //Update token
            self.updateToken()
            
            //Load Airports Data
            self.preLoadAirportsData()
            
            //Firebase Database Connection Checking
            let connectedRef = Database.database().reference(withPath: ".info/connected")
            connectedRef.observe(.value, with: { snapshot in
                if snapshot.value as? Bool ?? false {
                    self.hasConnected = true
                    self.isConnected = true
                    
                } else {
                    self.isConnected = false
                }
            })
            
            self.reloadDataTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true)
        
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.reloadDataTimer?.invalidate()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gradient Background color for tableView
        self.setTableViewBackgroundGradient(sender: self, ColorHex.hexStringToUIColor(hex: "#F2B2AF"), ColorHex.hexStringToUIColor(hex: "#B68CE1"))
        
        //Check internet Connection
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        
        } else {
        
            // For use when the app is open & in the background
            self.locationManager.requestWhenInUseAuthorization()
            
            // If location services is enabled get the users location
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
            
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 75
            
            //Load view to cover all screen
            let mainWindow = UIApplication.shared.keyWindow!
            self.overlayView = UIView(frame: CGRect(x: mainWindow.frame.origin.x, y: mainWindow.frame.origin.y, width: mainWindow.frame.width, height: mainWindow.frame.height))
            
            overlayView.backgroundColor = ColorHex.hexStringToUIColor(hex: "#B68CE1")
            mainWindow.addSubview(overlayView);
            
            let imageName = "Logo"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            let screenSize: CGRect = UIScreen.main.bounds
            
            imageView.frame = CGRect(x: 1, y: 1, width: screenSize.width * 0.5, height: screenSize.height * 0.35)
            imageView.center = self.view.center
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            self.overlayView.addSubview(imageView)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.securityCheckPoint()
            }
        }
       
    }
    
    //MARK: - PreLoad airports data
    func preLoadAirportsData() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Airports")
        
        //Ordenamos los aeropuertos por distancia
        let sortByDistance = NSSortDescriptor(key: #keyPath(Airports.distance),
                                              ascending: true)
        fetchRequest.sortDescriptors = [sortByDistance]
        
        do {
            airports = try managedContext.fetch(fetchRequest)
            
            if let lastAirportDistance = airports.last?.value(forKey: "distance") as? Double {
                //print ("Last Airport Distance:  \(lastAirportDistance)")
                let distanceZero: Bool = lastAirportDistance == Double(0.0)
                print ("Need to reload aiports data?: \(distanceZero)")
                
                if distanceZero {
                    
                    //Delete previous data
                    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Airports")
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                    
                    do {
                        try managedContext.execute(deleteRequest)
                        try managedContext.save()
                        
                    } catch {
                        print ("There was an error deleting airports data")
                    }
                    //Loading airports data
                    dataAirports.loadJSONAirportsData()
                    
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch Airports Data: \(error), \(error.userInfo)")
        }
    }
    

    func do_table_refresh()
    {
        self.tableView.reloadData()
        SwiftSpinner.hide()
        
        //Pop Over alert when there are not requests
        guard let exchangeRequestsCount = self.exchangeRequests?.count else {return}
        
        if (exchangeRequestsCount  == 0) && (self.exReqCountCheck == 0) {
            
            let alert = UIAlertController(title: "Add New Flights", message: "You don't have any flight yet. Press button 'Search' and post your flight. We will send you a message if we find a tripper in your flight", preferredStyle: UIAlertController.Style.alert)
            
            let action: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler:{
                (action) in
                //Check if profile is completed
                self.checkProfileCompleted()
            })
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
            //Count to 1
            self.exReqCountCheck = 1
        } else {
            self.checkProfileCompleted()
        }
    }
    
    @objc func loadData() {
        
        //Remove all exRequest and reload table
        self.exchangeRequests?.removeAll()
        self.tableView.reloadData()
        
        //Check internet Connection
        if self.currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
        
            DispatchQueue.main.async{
                
                
                SwiftSpinner.show("Loading Flights Pool")
                SwiftSpinner.show(delay: 5.0, title: "Low Connectivity...")
                
                guard let firUser = Auth.auth().currentUser else {return}
                ExchangeRequestService.fetchRequests(for: firUser, completion: { (exRequest) in
                    
                    self.exchangeRequests = exRequest
                    DispatchQueue.main.async(execute: {self.do_table_refresh()})
                    
                })
                
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setEditing(false, animated: true)
        self.editButton.setTitle("Delete", for: .normal)
        
        self.loadData()
        
    }
    
    
    
    //MARK: - Remove-Edit-Modify Flights
    @IBAction func toggleEditingMode(_ sender: UIButton){
        
        if self.exchangeRequests?.count ?? 0 > 0 {
        
            if isEditing {
                
                setEditing(false, animated: true)
                editButton.setTitle("Delete", for: .normal)
                
                
            } else {
                
                setEditing(true, animated: true)
                editButton.setTitle("Cancel", for: .normal)
                
            }
        } else {
            
            editButton.setTitle("Delete", for: .normal)
            
            //Animation failed request
            let bounds = self.editButton.bounds
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                self.editButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
            }, completion: nil)
            self.editButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            self.showAlert(title: "No Flights to Delete", description: "You should add a flight first")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //MARK: - Action button to create Exchange Request
    @IBAction func toCreateRequest(_ sender: UIButton) {
        
        if (self.hasConnected == false) && (self.isConnected == false) {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection and try later", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            
            //Cancel perform segue if there are 5 or more Exchange Requests
            guard let exchangeRequestsCount = self.exchangeRequests?.count else {
                print("Error counting Exchange Request")
                return}
            
            if exchangeRequestsCount  >= 5 {
                
                let alert = UIAlertController(title: "Max Flights Reached", message: "You cannot have more than 5 flights", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.exchangeRequests?.removeAll()
                self.tableView.reloadData()
                self.performSegue(withIdentifier: Constants.Segue.toSearchFlight, sender: sender)
            }
        }
        
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (exchangeRequests == nil) ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchangeRequests!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let exRequest = exchangeRequests![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExRequestCell", for: indexPath) as! ExRequestCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        let airport = exRequest.airport
        let airline = exRequest.airline
        let flight = exRequest.flight
        let date = exRequest.date
        
        //Matches
        let exRequestIdWanted = (date + "," + flight )
        
        //Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        if let dateF = dateFormatter.date(from: date){
            let dateFormatterAlt = DateFormatter()
            dateFormatterAlt.locale = Locale(identifier: "en")
            dateFormatterAlt.timeZone = TimeZone.current
            dateFormatterAlt.dateStyle = .medium
            let dateCell = dateFormatterAlt.string(from: dateF)
            
            cell.dateLabel.text = dateCell
        } else {
            cell.dateLabel.text = date
        }
        
        ExchangeRequestService.numberOfMatchesExRequest(exRequestId: exRequestIdWanted, completion: { (matches) in
            cell.matches.text = "\(matches)"
            
        })
        
        cell.airportLabel.text = airport
        cell.airlineLabel.text = airline
        cell.flightLabel.text = flight
        
        
        return cell
    }
    
    
    //MARK:- Exchange TableView row actions (Delete / Edit)
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! ExRequestCell
            guard let date = cell.dateLabel.text,
                let flight = cell.flightLabel.text
            
                else {return}
            
            //Format date
            let dateFormatter = DateFormatter()
            let dateFommatterAlt = DateFormatter()
            
            dateFormatter.dateStyle = .medium
            dateFormatter.locale = Locale(identifier: "en")
            dateFormatter.timeZone = TimeZone.current
            guard let dateF = dateFormatter.date(from: date) else {return}
            dateFommatterAlt.dateFormat = "ddMMyyyy"
            let dateS = dateFommatterAlt.string(from: dateF)
            
            
            let exRequestId = (dateS + "," + flight)
            
            print("exRequest to Delete: \(exRequestId)")
            
            guard let firUser = Auth.auth().currentUser else {return}
            
            //Alert Delete Exchange Request
            let title = "Delete Flight \(flight)?"
            let message = "Are you sure you want to delete this Flight?"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            //Cancel Action
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive,
                                             handler: { (action) -> Void in
                                                
                                                //Search value in database ExRequest node
                                                let refExchangeNode = Database.database().reference().child("exRequests").child(firUser.uid).child(exRequestId)
                                                refExchangeNode.removeValue()
                                                
                                                let refExIdsNode = Database.database().reference().child("exRequestsIds").child(exRequestId).child(firUser.uid)
                                                refExIdsNode.removeValue()
                                                
                                                ExchangeRequestService.fetchRequests(for: firUser, completion: { (exRequest) in
                                                    
                                                    self.exchangeRequests = exRequest
                                                    self.tableView.reloadData()
                                                    
                                                })
            })
            
            //Delete Action
            ac.addAction(deleteAction)
            
            //Present Alert Controller
            self.present(ac, animated: true, completion: nil)
        }
        
        return [delete]
    }
    
    //MARK: - Delete Exchange Requests
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            let cell = tableView.cellForRow(at: indexPath) as! ExRequestCell
            guard let date = cell.dateLabel.text,
                let flight = cell.flightLabel.text
                else {return}
            
            //Format date
            let dateFormatter = DateFormatter()
            let dateFommatterAlt = DateFormatter()
            
            dateFormatter.dateStyle = .medium
            dateFormatter.locale = Locale(identifier: "en")
            dateFormatter.timeZone = TimeZone.current
            guard let dateF = dateFormatter.date(from: date) else {return}
            dateFommatterAlt.dateFormat = "ddMMyyyy"
            let dateS = dateFommatterAlt.string(from: dateF)
            
            let exRequestId = (dateS + "," + flight)
            
            print("exRequest to Delete: \(exRequestId)")
            
            guard let firUser = Auth.auth().currentUser else {return}
            
            //Alert Delete Exchange Request
            let title = "Delete Flight \(flight)?"
            let message = "Are you sure you want to delete this flight?"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            //Cancel Action
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive,
                                             handler: { (action) -> Void in
                                                
                                                //Search value in database ExRequest node
                                                let refExchangeNode = Database.database().reference().child("exRequests").child(firUser.uid).child(exRequestId)
                                                refExchangeNode.removeValue()
                                                
                                                let refExIdsNode = Database.database().reference().child("exRequestsIds").child(exRequestId).child(firUser.uid)
                                                refExIdsNode.removeValue()
                                                
                                                ExchangeRequestService.fetchRequests(for: firUser, completion: { (exRequest) in
                                                    
                                                    self.exchangeRequests = exRequest
                                                    self.tableView.reloadData()
                                                    
                                                })
            })
            
            //Delete Action
            ac.addAction(deleteAction)
            
            //Present Alert Controller
            present(ac, animated: true, completion: nil)
        default:
            return
        }
    }
    
    //MARK: - Move Exchange Requests
    func moveItem(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        // Get reference to object being moved so you can reinsert it
        let movedItem = exchangeRequests![fromIndex]
        
        // Remove item from array
        exchangeRequests!.remove(at: fromIndex)
        
        // Insert item in array at new location
        exchangeRequests!.insert(movedItem, at: toIndex)
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // Update the model
        self.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    //MARK: - Prepare data to pass to Match Exchange View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.toMatchExRequest {
            
            //Figure out which row was taped
            if let row = tableView.indexPathForSelectedRow?.row {
                
                //Exchange Request Selected info variable defined to pass to MatchViewController
                let exReq = exchangeRequests![row]
                
                //Build inverse Ex Req
                let flight = exReq.flight
                let date = exReq.date
                
                let exRequestId = (date + "," + flight )
                
                let matchViewContoller = segue.destination as! MatchViewController
                matchViewContoller.exRequestId = exRequestId
            }
            
        }
    }
    
    //MARK: - Perform segue when row tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ExRequestCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        if (self.hasConnected == false) && (self.isConnected == false) {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection and try later", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            if !isEditing {
               
                let matches = cell.matches.text
                
                if matches == "0" {
                    //Alert if username has more than 12 characters
                    let alert = UIAlertController(title: "No Trippers found", message: "Not found any user for this flight. You will receive a notification when an user add your flight", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                } else {
                    
                    self.performSegue(withIdentifier: Constants.Segue.toMatchExRequest, sender: self)
                }
            }
        }
    }
    //MARK: - Update Token
    func updateToken() {
        
        guard let firUser = Auth.auth().currentUser,
            let token = Messaging.messaging().fcmToken
            else {return}
        
        let ref = Database.database().reference().child("users").child(firUser.uid).child("token")
        ref.setValue(token)
        print("Actual token is: \(token)")
        
    }
    
    //MARK: - Authenticate FaceId / Biometrics / Password
    func securityCheckPoint() {
    
        print("Loading security check point")
        
        
        TJBioAuthenticator.shared.authenticateUserWithBioMetrics(success: {
            // Biometric Authentication success
            print("Ok Access")
            DispatchQueue.main.async {
                self.overlayView.removeFromSuperview()
            }
            
            
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
                    DispatchQueue.main.async {
                        //Use Storyboard+Utility.swift logic (extensions)
                        let initialViewController = UIStoryboard.initialViewController(for: .login)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    }
                    
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
            
            print("Ok Access")
            DispatchQueue.main.async {
                self.overlayView.removeFromSuperview()
            }
            
        }) { (error) in
            
            
            self.showAlert(title: "Error", description: error.getMessage())
            guard Auth.auth().currentUser != nil else {
                return
            }
            do {
                try Auth.auth().signOut()
                
                DispatchQueue.main.async {
                    //Use Storyboard+Utility.swift logic (extensions)
                    let initialViewController = UIStoryboard.initialViewController(for: .login)
                    self.view.window?.rootViewController = initialViewController
                    self.view.window?.makeKeyAndVisible()
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
    
}
