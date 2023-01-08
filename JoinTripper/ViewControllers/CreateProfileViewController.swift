//
//  CreateProfileViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import CoreData
import CoreLocation
import SafariServices
import SwiftSpinner

//MARK: - Protocol used for sending countries data back
protocol CountriesDataEnteredDelegate: class {
    func userDidEnterCountriesInfo(country: String )
}

//MARK: - Protocol used for sending Languages data back
protocol LanguagesDataEnteredDelegate: class {
    func userDidEnterLanguagesInfo(languages: [String] )
}

class CreateProfileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,  CountriesDataEnteredDelegate, LanguagesDataEnteredDelegate, UIToolbarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var photoTextField: UITextField!
    @IBOutlet weak var languagesTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var languagesLabel: UILabel!
    
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsSwitch: UISwitch!
    
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var privacySwitch: UISwitch!
    
    //picker values
    let picker = UIPickerView()
    var selectedRow = 0
    //date picker
    var datePickerView: UIDatePicker = UIDatePicker()
    var toolBarDatePicker:UIToolbar = UIToolbar()
    //photo helper
    let photoHelper = MCPhotoHelper()
    //FaceDetection
    let options = VisionFaceDetectorOptions()
    lazy var vision = Vision.vision()
    //Create Button
    @IBOutlet weak var createButton: UIButton!
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    //Core data airports
    let dataAirports = DataAPI()
    var airports: [NSManagedObject] = []
    
    //MARK: Method to send value of datePickerView to dateOfBirthTextField
    @IBAction func dateOfBirthTextFieldEditing(_ sender: UITextField) {
        
        if sender == dateOfBirthTextField {
            
            datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: .valueChanged)
            
            sender.inputView = datePickerView}
        
    }
    
    //MARK: - DatePickerView
    func addDatePickerViewToTextField() {
        
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.locale = Locale(identifier: "en")
        datePickerView.timeZone = TimeZone.current
        
        
        //DatePicker config
        let currentDate = NSDate()
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let dateComponents = NSDateComponents()
        dateComponents.year = -120
        let minDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        dateComponents.year = -18
        let maxDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        
        datePickerView.minimumDate = minDate
        datePickerView.maximumDate = maxDate
        
        toolBarDatePicker.barStyle = UIBarStyle.default
        toolBarDatePicker.isTranslucent = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed(sender:)))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBarDatePicker.setItems([flexibleSpace,doneButton], animated: true)
        toolBarDatePicker.isUserInteractionEnabled = true
        toolBarDatePicker.sizeToFit()
        
        dateOfBirthTextField.inputAccessoryView = toolBarDatePicker
        
        dateOfBirthTextField.inputView = datePickerView
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.timeZone = TimeZone.current
        
        dateOfBirthTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        dateOfBirthTextField.resignFirstResponder()
    }
    
    //MARK: Display Alert Regarding iMessage constraint email
    func loadInitialiMessageWarning() {
        
        guard let firUser = Auth.auth().currentUser else {return}
        
        guard let email = firUser.email else {return}
        
        let alert = UIAlertController(title: "iMessage", message: "This app uses iMessage, please verify your email \(email) privileges, further info bellow to add new email address to iMessage", preferredStyle: UIAlertController.Style.alert)
        
        let action: UIAlertAction = UIAlertAction(title: "Info", style: .default, handler: {
            (action) in
            
            let urlString = "https://support.apple.com/en-au/HT201356"
            
            if let url = URL(string: urlString) {
                let vc = SFSafariViewController(url: url)
                vc.delegate = self as? SFSafariViewControllerDelegate
                
                self.present(vc, animated: true)
            }
            
            func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
                self.dismiss(animated: true)
            }
        })
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func loadLocalLangTextField() {
        
        //Search local preferred lang
        guard let localeLang = Locale.preferredLanguages[0].split(separator: "-").first?.uppercased()
            else {return }
        print("iphone Language: \(localeLang)")
        
        //Language Message
        var langMessage = String ()
        
        guard let countryCode = NSLocale.current.regionCode else {return}
        
        //Search values to complete text fields
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //Languages text field filling
        let fetchRequestLanguages =
            NSFetchRequest<NSManagedObject>(entityName: "Languages")
        
        let fetchRequestCountryLang = NSFetchRequest<NSManagedObject>(entityName: "Languages")
        
        fetchRequestLanguages.predicate = NSPredicate(format: "code contains[cd] %@", localeLang)
        fetchRequestCountryLang.predicate = NSPredicate(format: "code contains[cd] %@", countryCode)
        
        do {
            let languages = try managedContext.fetch(fetchRequestLanguages) as [NSManagedObject]
            
            guard let nameLanguage = languages.first?.value(forKey: "name"),
                let nameLanguageString = nameLanguage as? String
                else {return}
            print("Language Name: \(nameLanguageString)")
            //Load always English language
            
            //Fill Languages text field with 3 first characters
            let languageStrRed = String(nameLanguageString.prefix(3))
            
            langMessage = "Eng,\(languageStrRed)"
            
            //Search country iphone settings in Languages
            let langCountry = try managedContext.fetch(fetchRequestCountryLang) as [NSManagedObject]
            
            guard let nameLangCountry = langCountry.first?.value(forKey: "name"),
                let nameLangCountryString = nameLangCountry as? String
                else {
                    //If not have found any country language, put lang iphone settings alone
                    self.languagesTextField.text = langMessage
                    return}
            
            let nameLangCountryStringRed = String(nameLangCountryString.prefix(3))
            
            if nameLanguageString == nameLangCountryString {
                self.languagesTextField.text = langMessage
            } else {
                
                langMessage = "Eng,\(languageStrRed),\(nameLangCountryStringRed)"
                self.languagesTextField.text = langMessage
            }
            
        } catch let error as NSError { print("Could not fetch Languages Data: \(error), \(error.userInfo)")
            self.languagesTextField.text = "Eng"
            
        }
    }
    
    func loadCountryTextField() {
        
        guard let countryCode = NSLocale.current.regionCode else {return}
        print("iphone Country: \(countryCode)")
        
        //Search values to complete text fields
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //Languages text field filling
        let fetchRequestCountry =
            NSFetchRequest<NSManagedObject>(entityName: "Countries")
        fetchRequestCountry.predicate = NSPredicate(format: "code contains[cd] %@", countryCode)
        
        do {
            let countries = try managedContext.fetch(fetchRequestCountry) as [NSManagedObject]
            guard let nameCountry = countries.first?.value(forKey: "name"),
                let nameCountryString = nameCountry as? String
                else {return}
            print("Country Name: \(nameCountryString)")
            
            self.countryTextField.text = nameCountryString
            
        } catch let error as NSError { print("Could not fetch Countries Data: \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - Call ViewDidAppear to Preload Airports data
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Load Airports Data
        self.preLoadAirportsData()
        
    }
    
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
    
    //MARK:- Button tapped Terms & Conditions
    @IBAction func termsButtonTapped(_ sender: UIButton){
        
        let urlString = "https://jointripper.com/terms"
        
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            vc.configuration.entersReaderIfAvailable = true
            vc.delegate = self as? SFSafariViewControllerDelegate
            
            
            self.present(vc, animated: true)
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            self.dismiss(animated: true)
        }
        
    }
    
    //MARK:- Button tapped Terms & Conditions
    @IBAction func privacyButtonTapped(_ sender: UIButton){
        
        let urlString = "https://jointripper.com/privacy"
        
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            vc.configuration.entersReaderIfAvailable = true
            vc.delegate = self as? SFSafariViewControllerDelegate
            
            self.present(vc, animated: true)
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            self.dismiss(animated: true)
        }
        
    }
    
    //MARK: - Function to upload/download/detect faces
    func checkFacesProcess(){
        //Manage image loaded into Firebase Storage
        
        guard let firUser = Auth.auth().currentUser else {
            print("No firuser")
            return}
        
        //Load and present image profile
        // Reference to an image file in Firebase Storage
        let imageName = firUser.uid + ".jpg"
        let imageRef = Storage.storage().reference().child(imageName)
        
        photoHelper.completionHandler = { image in
            print("handling image...")
            
            let group = DispatchGroup()
            group.enter()
            SwiftSpinner.show("Analyzing photo")
            self.createPostURL(for: image)
            
            group.leave()
            
            group.notify(queue: DispatchQueue.main){
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                    
                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("Error downloading profile image: \(error)")
                            self.photoTextField.text = ""
                            SwiftSpinner.hide()
                            
                            //Alert if faces detected is not equal to 1
                            let alert = UIAlertController(title: "Error Analyzing Photo", message: "Try again later", preferredStyle: UIAlertController.Style.alert)
                            
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            // Data for profile image is returned
                            let image = UIImage(data: data!)
                            
                            if let imageUpload: UIImage = image {
                                self.detectFaces(image: imageUpload, completion: {(faces) in
                                    if faces != 1 {
                                        self.photoTextField.text = ""
                                        SwiftSpinner.hide()
                                        
                                        //Alert if faces detected is not equal to 1
                                        let alert = UIAlertController(title: "Error Profile Photo", message: "Pick or take a photo profile of you in order to make easier other users recognizing you. Do not include other's people photo", preferredStyle: UIAlertController.Style.alert)
                                        
                                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                    } else {
                                        self.photoTextField.text = "Uploaded"
                                        SwiftSpinner.hide()
                                    }
                                })
                            } else {
                                print ("Error on Face Id to image profile")
                                //Alert if faces detected is not equal to 1
                                self.photoTextField.text = ""
                                let alert = UIAlertController(title: "Error Analyzing Photo", message: "Try again later", preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                SwiftSpinner.hide()
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use when the app is open & in the background
        self.locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
        
        // Do any additional setup after loading the view.
        
        options.landmarkMode = .all
        options.classificationMode = .all
        options.minFaceSize = CGFloat(0.1)
        
        addDatePickerViewToTextField()
        dateOfBirthTextFieldEditing(dateOfBirthTextField)
        datePickerValueChanged(sender: datePickerView)
        genderTextField.text = ""
        
        picker.delegate = self
        picker.dataSource = self
        genderTextField.inputView = picker
        doneButtonGenderPickerView()
        
        countryTextField.delegate = self
        languagesTextField.delegate = self
        usernameTextField.delegate = self
        photoTextField.delegate = self
        
        //Put generic date of birth (Optional field)
        self.dateOfBirthTextField.text = "--"
        self.genderTextField.text = "--"
        
        self.checkFacesProcess()
        
        //Initial message
        self.loadInitialiMessageWarning()
        
        //Local Languages preload
        self.loadLocalLangTextField()
        
        //Country preload
        self.loadCountryTextField()
        
        //Adjust Text Label
        self.usernameLabel.adjustsFontSizeToFitWidth = true
        let usernameLabelHeight = usernameLabel.optimalHeight
        usernameLabel.frame = CGRect(x: usernameLabel.frame.origin.x, y: usernameLabel.frame.origin.y, width: usernameLabel.frame.width, height: usernameLabelHeight)
        
        self.genderLabel.adjustsFontSizeToFitWidth = true
        let genderLabelHeight = genderLabel.optimalHeight
        genderLabel.frame = CGRect(x: genderLabel.frame.origin.x, y: genderLabel.frame.origin.y, width: genderLabel.frame.width, height: genderLabelHeight)
        
        self.dateOfBirthLabel.adjustsFontSizeToFitWidth = true
        let dateOfBirthLabelHeight = dateOfBirthLabel.optimalHeight
        dateOfBirthLabel.frame = CGRect(x: dateOfBirthLabel.frame.origin.x, y: dateOfBirthLabel.frame.origin.y, width: dateOfBirthLabel.frame.width, height: dateOfBirthLabelHeight)
        
        self.countryLabel.adjustsFontSizeToFitWidth = true
        let countryLabelHeight = countryLabel.optimalHeight
        countryLabel.frame = CGRect(x: countryLabel.frame.origin.x, y: countryLabel.frame.origin.y, width: countryLabel.frame.width, height: countryLabelHeight)
        
        self.photoLabel.adjustsFontSizeToFitWidth = true
        let photoLabelHeight = photoLabel.optimalHeight
        photoLabel.frame = CGRect(x: photoLabel.frame.origin.x, y: photoLabel.frame.origin.y, width: photoLabel.frame.width, height: photoLabelHeight)
        
        self.languagesLabel.adjustsFontSizeToFitWidth = true
        let languagesLabelHeight = languagesLabel.optimalHeight
        languagesLabel.frame = CGRect(x: languagesLabel.frame.origin.x, y: languagesLabel.frame.origin.y, width: languagesLabel.frame.width, height: languagesLabelHeight)
        
    }
    
    //Not activate keyboard when editing these fields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        self.view.endEditing(true)
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: UIPickerView for Gender field
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("Gender Count: \(Gender.allCases.count)")
        return Gender.allCases.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let genderSelection = Gender.allCases[row]
        
        switch genderSelection {
        
        case .male:  return "Male"
        case .female: return "Female"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Row selected: \(row)")
        self.selectedRow = row
    }
    
    //Done Button config -toolbar-
    func doneButtonGenderPickerView(){
        
        let pickerView = picker
        pickerView.backgroundColor = .clear
        pickerView.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        genderTextField.inputView = pickerView
        genderTextField.inputAccessoryView = toolBar
    }
    
    
    @objc func donePicker() {
        self.genderTextField.text = Gender(rawValue: selectedRow)?.description
        genderTextField.resignFirstResponder()
    }
    
    //MARK: Define actions according TextField selected
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == countryTextField{
            self.performSegue(withIdentifier: Constants.Segue.showCountries, sender: self)
            
        }
        else if textField == usernameTextField{
            
            return true
        }
        else if textField == languagesTextField{
            
            self.performSegue(withIdentifier: Constants.Segue.showLanguages, sender: self)
        }
        else if textField == photoTextField {
            
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
                
                if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                    print("Accesing to photoHelpert to pick up from library")
                    self.photoHelper.presentActionSheet(from: self)
                }
            })
        }
        
        return false
    }
    
    // MARK: Required method of our custom DataEnteredDelegate protocol. Set country 1 value
    func userDidEnterCountriesInfo(country: String) {
        countryTextField.text = country
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Required method of of our custom DataEnteredDelegate protocolo for languages
    func userDidEnterLanguagesInfo(languages: [String]) {
        //Fill Languages text field with 3 first characters
        
        var languagesArray: [String] = []
        
        for item in languages {
            languagesArray.append(String(item.prefix(3)))
        }
        
        let languagesString = languagesArray.joined(separator: ",")
        
        languagesTextField.text = languagesString
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.showCountries, let countriesViewController = segue.destination as? CountriesViewController  {
            countriesViewController.delegate = self
            
            //Transfer country text field to countries view controller
            if let countryText = self.countryTextField.text {
                countriesViewController.countrySelected = countryText
            }
        }
        else if segue.identifier == Constants.Segue.showLanguages, let languagesViewController = segue.destination as? LanguagesViewController  {
            languagesViewController.delegate = self
            
            //Preload languages with check mark
            var languagesArray = [String]()
            
            //Create Array String to transfer Languagesview Controller
            if let languagesInit = languagesTextField.text {
                
                let languagesArrayInit = languagesInit.components(separatedBy: ",")
                
                for i in languagesArrayInit {
                    languagesArray.append(i)
                }
                
                print("User Languages with check mark: \(languagesArray)")
                
                //Transfer languages values
                languagesViewController.languagesArray = languagesArray
                
            }
        }
    }
    
    //MARK : Next button to write profile info
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        
        //Get a reference to current user logged to FB Database (Mandatory UID)
        guard let firUser = Auth.auth().currentUser else {return}
        
        
        //Get username text whihout trailing or leading spaces
        guard let username =  (usernameTextField.text)?.trimmingCharacters(in: .whitespaces),
            !username.isEmpty, (6 ... 20) ~= username.count, !username.contains(" ") else {
                
                //Alert if username has more than 12 characters
                let alert = UIAlertController(title: "Username limit characters", message: "Username must be between 6-20 characters without spaces inside", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                //Animation failed request
                let bounds = self.createButton.bounds
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                    self.createButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
                }, completion: nil)
                self.createButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
                
                return}
        
        //Verify there is not blank fields
        guard let gender = genderTextField.text, !gender.isEmpty, let photoProfile = photoTextField.text, !photoProfile.isEmpty, let dateOfBirth = dateOfBirthTextField.text, !dateOfBirth.isEmpty, let country = countryTextField.text, !country.isEmpty, let languages = languagesTextField.text, !languages.isEmpty   else{
            
            //Alert config
            let alert = UIAlertController(title: "Blank fields", message: "You must fill up all fields", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            //Animation failed request
            let bounds = self.createButton.bounds
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                self.createButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
            }, completion: nil)
            self.createButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            return
            
        }
        
        //Verify if switch of Terms and conditions is Active
        if !self.termsSwitch.isOn {
            //Alert config
            let alert = UIAlertController(title: "Terms & Conditions", message: "You must accept our Terms and Conditions", preferredStyle: UIAlertController.Style.alert)
            
            let action: UIAlertAction = UIAlertAction(title: "Read Terms & Conditions", style: .default, handler: {
                (action) in
                
                let urlString = "https://jointripper.com/terms"
                
                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    vc.configuration.entersReaderIfAvailable = true
                    vc.delegate = self as? SFSafariViewControllerDelegate
                    
                    
                    self.present(vc, animated: true)
                }
                
                func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
                    self.dismiss(animated: true)
                }
            })
            
            alert.addAction(action)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            //Animation failed request
            let bounds = self.createButton.bounds
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                self.createButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
            }, completion: nil)
            self.createButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            return
            
        }
        
        //Verify if switch of Terms and conditions is Active
        if !self.privacySwitch.isOn {
            //Alert config
            let alert = UIAlertController(title: "Privacy Policy", message: "You must accept our Privacy Policy", preferredStyle: UIAlertController.Style.alert)
            
            let action: UIAlertAction = UIAlertAction(title: "Read Privacy Policy", style: .default, handler: {
                (action) in
                
                let urlString = "https://jointripper.com/privacy"
                
                if let url = URL(string: urlString) {
                    let vc = SFSafariViewController(url: url)
                    vc.configuration.entersReaderIfAvailable = true
                    vc.delegate = self as? SFSafariViewControllerDelegate
                    
                    self.present(vc, animated: true)
                }
                
                func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
                    self.dismiss(animated: true)
                }
            })
            
            alert.addAction(action)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            //Animation failed request
            let bounds = self.createButton.bounds
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                self.createButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
            }, completion: nil)
            self.createButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            return
            
        }
        
        //Birth Date Formatter
        let dateFormatter = DateFormatter()
        let dateFommatterAlt = DateFormatter()
        guard let dateString = dateOfBirthTextField.text else {return}
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.timeZone = TimeZone.current
        
        var dateOfBirthString:String
        
        //Format date only if replyed
        if dateString != "--" {
            
            print ("Date String is a Date")
            guard let dateF = dateFormatter.date(from: dateString) else {return}
            dateFommatterAlt.dateFormat = "ddMMyyyy"
            dateOfBirthString = dateFommatterAlt.string(from: dateF)
        
        } else {
            
            print ("Date String is --")
            dateOfBirthString = dateString
            
        }
        //Use UserService layer for writing username field to database
        UserService.create(firUser, username: username, gender: gender, dateOfBirth: dateOfBirthString, country: country, languages: languages) { (user) in
            
            guard let user = user else {
                
                let alert = UIAlertController(title: "Username already used", message: "Try another username", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                //Animation failed request
                let bounds = self.createButton.bounds
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                    self.createButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
                }, completion: nil)
                self.createButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
                
                return
            }
            
            //Singleton pattern - User.swift
            do { try  User.setCurrent(user, writeToUserDefaults: true)} catch let error as NSError {
                print ("Error set Current User: \(error.debugDescription)")
            }
            
            //Dismiss keyboard
            self.view.endEditing(true)
            
            //Use Storyboard+Utility.swift logic (extensions)
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            
        }
    }
    
    // MARK: Dismiss Keyboard tapping outside keypad
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        usernameTextField.resignFirstResponder()
        dateOfBirthTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        
    }
    
    //MARK: - ML Kit code
    func detectFaces(image:UIImage, completion: @escaping(Int?) -> Void) {
        
        let faceDetector = vision.faceDetector(options: options)
        let visionImage = VisionImage(image: image)
        
        faceDetector.process(visionImage) { (faces, error) in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                print("No Face Detected: \(error.debugDescription)")
                completion(0)
                return
            }
            print("I see \(faces.count) face(s)")
            
            for face in faces {
                if face.hasLeftEyeOpenProbability {
                    if face.leftEyeOpenProbability < 0.4 {
                        print("The left eye is not open!")
                    } else {
                        print( "The left eye is open!")
                    }
                }
                
                if face.hasRightEyeOpenProbability {
                    if face.rightEyeOpenProbability < 0.4 {
                        print( "The right eye is not open!")
                    } else {
                        print("The right eye is open!")
                    }
                }
                
                if face.hasSmilingProbability {
                    if face.smilingProbability < 0.3 {
                        print("This person is not smiling")
                    } else {
                        print("This person is smiling")
                    }
                }
            }
            
            completion(faces.count)
        }
    }
    
    //MARK: Create a Post from an image an return urlString
    var completionHandler: ((URL) -> Void)?
    
    func createPostURL(for image: UIImage) {
        
        guard let firUser = Auth.auth().currentUser else {return}
        
        let imageRef = Storage.storage().reference().child(firUser.uid + ".jpg")
        
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            
            guard let downloadURL  = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            print("image url: \(urlString)")
            self.completionHandler?(downloadURL)
        }
    }
    
}




