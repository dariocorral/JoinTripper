//
//  ModifyProfileViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 14/01/2019.
//  Copyright © 2019 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Firebase
import Photos
import CoreData
import TJBioAuthentication
import SwiftSpinner


//MARK: - Protocol used for sending countries data back
protocol CountriesDataEnteredModifyProfileDelegate: class {
    func userDidEnterCountriesInfo(country: String )
}

//MARK: - Protocol used for sending Languages data back
protocol LanguagesDataEnteredModifyProfileDelegate: class {
    func userDidEnterLanguagesInfo(languages: [String] )
}

class ModifyProfileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,  CountriesDataEnteredModifyProfileDelegate, LanguagesDataEnteredModifyProfileDelegate, UIToolbarDelegate {
    
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
    
    
    //Variables from User Profile
    var dateOfBirth = String ()
    var gender = String ()
    var username = String ()
    var country = String ()
    var languages = String()
    
    //picker values
    let picker = UIPickerView()
    var selectedRow = 0
    //date picker
    var datePickerView: UIDatePicker = UIDatePicker()
    var toolBarDatePicker:UIToolbar = UIToolbar()
    //photo helper
    let photoHelper = MCPhotoHelper()
    //Modify Button
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    //FaceDetection
    let options = VisionFaceDetectorOptions()
    lazy var vision = Vision.vision()
    
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
    
    //MARK: - Fill text fields
    func fillTextFields() {
        self.countryTextField.text = self.country
        self.usernameTextField.text = self.username
        self.photoTextField.text = "Change photo"
        self.genderTextField.text = self.gender
        
        //Fill Languages text field with 3 first characters
        let languagesComp = self.languages.components(separatedBy: ",")
        var languagesArray: [String] = []
        
        for item in languagesComp {
            languagesArray.append(String(item.prefix(3)))
        }
        
        let languagesString = languagesArray.joined(separator: ",")
        
        self.languagesTextField.text = languagesString
        
        //Dataformatter conversion
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        if let dateF = dateFormatter.date(from: self.dateOfBirth){
            let dateFormatterAlt = DateFormatter()
            dateFormatterAlt.locale = Locale(identifier: "en")
            dateFormatterAlt.timeZone = TimeZone.current
            dateFormatterAlt.dateStyle = .medium
            let dateOfBirthFormatted = dateFormatterAlt.string(from: dateF)
            
            self.dateOfBirthTextField.text = dateOfBirthFormatted
        }else {
            self.dateOfBirthTextField.text = self.dateOfBirth
        }
    }
    
    //MARK: - Check if there is somechange in text fields
    func checkChangesTextFields() -> Bool {
        
        //Fill Languages text field with 3 first characters
        let languagesComp = self.languages.components(separatedBy: ",")
        var languagesArray: [String] = []
        
        for item in languagesComp {
            languagesArray.append(String(item.prefix(3)))
        }
        
        let languagesString = languagesArray.joined(separator: ",")
        
        //Dataformatter conversion
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        if let dateF = dateFormatter.date(from: self.dateOfBirth){
            let dateFormatterAlt = DateFormatter()
            dateFormatterAlt.locale = Locale(identifier: "en")
            dateFormatterAlt.timeZone = TimeZone.current
            dateFormatterAlt.dateStyle = .medium
            let dateOfBirthFormatted = dateFormatterAlt.string(from: dateF)
            print("Date of birth formatted: \(dateOfBirthFormatted)")
            
            //Check Process
            if (self.usernameTextField.text == self.username) &&
                (self.countryTextField.text == self.country) &&
                (self.photoTextField.text == "Change photo") &&
                (self.genderTextField.text == self.gender) &&
                (self.languagesTextField.text == languagesString) &&
                (self.dateOfBirthTextField.text == dateOfBirthFormatted){
                
                return false} else {
                return true
            }
            
        } else {
            
            if self.dateOfBirth != "--"{
            
                self.dateOfBirthTextField.text = self.dateOfBirth
            
                //Check Process
                if (self.usernameTextField.text == self.username) &&
                    (self.countryTextField.text == self.country) &&
                    (self.photoTextField.text == "Change photo") &&
                    (self.genderTextField.text == self.gender) &&
                    (self.languagesTextField.text == languagesString) &&
                    (self.dateOfBirthTextField.text == self.dateOfBirth) {
                    
                    return false} else {
                    return true
                }
            
            } else {
                
                print("Date of birth: \(self.dateOfBirth)")
                print("Date of birth Field text: \(self.dateOfBirthTextField.text ?? "no birth Date text field")")
                
                //Check Process
                if (self.usernameTextField.text == self.username) &&
                    (self.countryTextField.text == self.country) &&
                    (self.photoTextField.text == "Change photo") &&
                    (self.genderTextField.text == self.gender) &&
                    (self.languagesTextField.text == languagesString) &&
                    (self.dateOfBirthTextField.text == "--") {
                    
                    return false} else {
                    return true
                }
                
            }
        }
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
            StorageService.modifyPost(for: image)
            
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
        
        // Do any additional setup after loading the view.
        options.landmarkMode = .all
        options.classificationMode = .all
        options.minFaceSize = CGFloat(0.1)
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        
        } else {
        
            self.checkFacesProcess()
            
            //Fill textFields
            self.fillTextFields()
            
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("Date of birth variable: \(self.dateOfBirth)")
        
        if self.dateOfBirth != "--" {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMyyyy"
            guard let dateF = dateFormatter.date(from: self.dateOfBirth) else {return}
            let dateFormatterAlt = DateFormatter()
            dateFormatterAlt.locale = Locale(identifier: "en")
            dateFormatterAlt.timeZone = TimeZone.current
            dateFormatterAlt.dateStyle = .medium
            let dateOfBirthFormatted = dateFormatterAlt.string(from: dateF)
            print("Date of birth formatted: \(dateOfBirthFormatted)")
        
            self.dateOfBirthTextField.text = dateOfBirthFormatted
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
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
        selectedRow = row
    }
    
    //Done Button config -toolbar-
    func doneButtonGenderPickerView(){
        
        let pickerView = picker
        pickerView.backgroundColor = .clear
        pickerView.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        genderTextField.inputView = pickerView
        genderTextField.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        self.genderTextField.text = Gender(rawValue: selectedRow)?.description
        genderTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.showCountries, let countriesViewController = segue.destination as? CountriesViewController  {
            countriesViewController.delegateModifyProfile = self
            
            //Transfer country text field to countries view controller
            if let countryText = self.countryTextField.text {
                countriesViewController.countrySelected = countryText
            }
            
        }
        else if segue.identifier == Constants.Segue.showLanguages, let languagesViewController = segue.destination as? LanguagesViewController  {
            languagesViewController.delegateModifyProfile = self
            
            //Create Array String to transfer Languagesview Controller
            let languagesArrayInit = self.languages.components(separatedBy: ",")
            
            var languagesArray = [String]()
            
            for i in languagesArrayInit {
                languagesArray.append(i)
            }
            print("User Languages with check mark: \(languagesArray)")
            
            //Transfer languages values
            languagesViewController.languagesArray = languagesArray
        }
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
        self.countryTextField.text = country
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Required method of of our custom DataEnteredDelegate protocolo for languages
    func userDidEnterLanguagesInfo(languages: [String]) {
        
        //Get first 3 characters
        var languagesArray: [String] = []
        
        for item in languages {
            languagesArray.append(String(item.prefix(3)))
        }
        
        let languagesString = languagesArray.joined(separator: ",")
        
        self.languagesTextField.text = languagesString
        navigationController?.popViewController(animated: true)
    }
    
    //MARK : Next button to write profile info
    @IBAction func modifyButtonTapped(_ sender: UIButton) {
        
        //Get a reference to current user logged to FB Database (Mandatory UID)
        guard let firUser = Auth.auth().currentUser else {return}
        
        //Check Changes in text fields
        let checkChanges = self.checkChangesTextFields()
        
        if checkChanges == false {
            
            //Animation failed request
            let bounds = self.modifyButton.bounds
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                self.modifyButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
            }, completion: nil)
            self.modifyButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            //Alert if username has more than 12 characters
            let alert = UIAlertController(title: "No Changes", message: "You did not change any field", preferredStyle:UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //Get username text whihout trailing or leading spaces
        guard let usernameNew =  (usernameTextField.text)?.trimmingCharacters(in: .whitespaces),
            !usernameNew.isEmpty, (6 ... 20) ~= usernameNew.count, !usernameNew.contains(" ") else {
                
                //Alert if username has more than 12 characters
                let alert = UIAlertController(title: "Username limit characters", message: "Username must be between 6-20 characters without spaces inside", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                //Animation failed request
                let bounds = self.modifyButton.bounds
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                    self.modifyButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
                }, completion: nil)
                self.modifyButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
                
                return}
        
        //Verify there is not blank fields
        guard let gender = genderTextField.text, !gender.isEmpty, let photoProfile = photoTextField.text, !photoProfile.isEmpty, let dateOfBirth = dateOfBirthTextField.text, !dateOfBirth.isEmpty, let country = countryTextField.text, !country.isEmpty, let languages = languagesTextField.text, !languages.isEmpty   else{
            
            //Alert config
            let alert = UIAlertController(title: "Blank fields", message: "You must fill up all fields", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            //Animation failed request
            let bounds = self.modifyButton.bounds
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                self.modifyButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
            }, completion: nil)
            self.modifyButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            return}
        
        //Birth Date Formatter
        let dateFormatter = DateFormatter()
        let dateFommatterAlt = DateFormatter()
        guard let dateString = dateOfBirthTextField.text else {return}
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.timeZone = TimeZone.current
        
        var dateOfBirthString: String
        
        if dateOfBirthTextField.text != "--" {
            guard let dateF = dateFormatter.date(from: dateString) else {return}
            dateFommatterAlt.dateFormat = "ddMMyyyy"
            dateOfBirthString = dateFommatterAlt.string(from: dateF)
        } else {
            dateOfBirthString = dateString
        }
        
        //Delete Old Username
        let ref = Database.database().reference().child("usernames").child(self.username)
        ref.removeValue()
        
        //Use UserService layer for writing username field to database
        UserService.create(firUser, username: usernameNew, gender: gender, dateOfBirth: dateOfBirthString, country: country, languages: languages) { (user) in
            
            guard let user = user else {
                
                let alert = UIAlertController(title: "Username already used", message: "Try another username", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                //Animation failed request
                let bounds = self.modifyButton.bounds
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                    self.modifyButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
                }, completion: nil)
                self.modifyButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
                
                return
            }
            
            //Singleton pattern - User.swift
            do {try User.setCurrent(user, writeToUserDefaults: true)}
            catch let error as NSError{
                print("Error Set Current User: \(error.debugDescription)")
            }
            
            //Dismiss keyboard
            self.view.endEditing(true)
            
            //Alert config
            let alert = UIAlertController(title: "Profile Modified", message: "Your profile has been modified", preferredStyle: UIAlertController.Style.alert)
            
            let action: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler:{
                (action) in
                self.navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteProfile(_ sender: UIButton){
        
        
        //Alert Delete Exchange Request
        let title = "Delete Profile"
        let message = "Are you sure you want to delete your account?"
        
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //Cancel Action
        ac.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive,
                                         handler: { (action) -> Void in
                                            
                                            self.securityCheckPoint()
        })
        //Delete Action
        ac.addAction(deleteAction)
        
        //Present Alert Controller
        present(ac, animated: true, completion: nil)
    }
    
    // MARK: Dismiss Keyboard tapping outside keypad
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        usernameTextField.resignFirstResponder()
        dateOfBirthTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        
    }
    
    //MARK: - Authenticate FaceId / Biometrics / Password
    func securityCheckPoint() {
        TJBioAuthenticator.shared.authenticateUserWithBioMetrics(success: {
            
            // Biometric Authentication success
            
            //User data
            guard let firUser = Auth.auth().currentUser else {return}
            
            //Delete usernames value
            UserService.show(forUID: firUser.uid, completion:{ (user) in
                guard let usernameDatabase = user?.username else {return}
                let username = usernameDatabase
                
                let refUsernames = Database.database().reference().child("usernames").child(username)
                refUsernames.removeValue()
            })
            
            //Delete process
            UserService.exRequestFromUserUid(firUser.uid, completion:{ (exRequests)
                in guard let exRequestsValues = exRequests else {return}
                print("Exrequest: \(exRequestsValues)")
                
                for value in exRequestsValues{
                    Database.database().reference().child("exRequestsIds").child(value).child(firUser.uid).removeValue()
                }
                
                Database.database().reference().child("exRequests").child(firUser.uid).removeValue() //Remove value from exRequest chain
                Database.database().reference().child("users").child(firUser.uid).removeValue()
                
                //Delete votes
                let refVotes = Database.database().reference().child("votes").child(firUser.uid)
                refVotes.removeValue()
                
                let imageRef = Storage.storage().reference().child(firUser.uid + ".jpg")
                //Delete old photo
                imageRef.delete { error in
                    if let error = error {
                        print("Error deleting profile image \(error)")
                    } else {
                        print("Image profile deleted")
                    }
                }
                
                //Delete user
                firUser.delete { error in
                    if let error = error {
                        
                        print("Error deleting user: \(error)")
                        //Use Storyboard+Utility.swift logic (extensions)
                        let initialViewController = UIStoryboard.initialViewController(for: .login)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                        
                    } else {
                        
                        print("User deleted")
                        //Alert config
                        let alert = UIAlertController(title: "Profile Deleted", message: "Your profile has been deleted", preferredStyle: UIAlertController.Style.alert)
                        
                        let action: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: {
                            (action) in
                            //Use Storyboard+Utility.swift logic (extensions)
                            let initialViewController = UIStoryboard.initialViewController(for: .login)
                            self.view.window?.rootViewController = initialViewController
                            self.view.window?.makeKeyAndVisible()
                        })
                        
                        alert.addAction(action)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            
        }) { (error) in
            // Biometric Authentication unsuccessful
            switch error{
            case .biometryLockedout:
                self.executePasscodeAuthentication()
            case .userCancel:
                
                DispatchQueue.main.async {
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
                
            case .failed:
                self.executePasscodeAuthentication()
                
            default:
                self.executePasscodeAuthentication()
            }
        }
    }
    func executePasscodeAuthentication(){
        TJBioAuthenticator.shared.authenticateUserWithPasscode(success: {
            
            //Segue
            //User data
            guard let firUser = Auth.auth().currentUser else {return}
            
            //Delete usernames value
            UserService.show(forUID: firUser.uid, completion:{ (user) in
                guard let usernameDatabase = user?.username else {return}
                let username = usernameDatabase
                
                let refUsernames = Database.database().reference().child("usernames").child(username)
                refUsernames.removeValue()
            })
            
            //Delete process
            UserService.exRequestFromUserUid(firUser.uid, completion:{ (exRequests)
                in guard let exRequestsValues = exRequests else {return}
                print("Exrequest: \(exRequestsValues)")
                
                for value in exRequestsValues{
                    Database.database().reference().child("exRequestsIds").child(value).child(firUser.uid).removeValue()
                }
                
                Database.database().reference().child("exRequests").child(firUser.uid).removeValue() //Remove value from exRequest chain
                Database.database().reference().child("users").child(firUser.uid).removeValue()
                
                //Delete votes
                let refVotes = Database.database().reference().child("votes").child(firUser.uid)
                refVotes.removeValue()
                
                let imageRef = Storage.storage().reference().child(firUser.uid + ".jpg")
                //Delete old photo
                imageRef.delete { error in
                    if let error = error {
                        print("Error deleting profile image \(error)")
                    } else {
                        print("Image profile deleted")
                    }
                }
                
                //Delete user
                firUser.delete { error in
                    if let error = error {
                        
                        print("Error deleting user: \(error)")
                        //Use Storyboard+Utility.swift logic (extensions)
                        let initialViewController = UIStoryboard.initialViewController(for: .login)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                        
                    } else {
                        
                        print("User deleted")
                        //Alert config
                        let alert = UIAlertController(title: "Profile Deleted", message: "Your profile has been deleted", preferredStyle: UIAlertController.Style.alert)
                        
                        let action: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: {
                            (action) in
                            //Use Storyboard+Utility.swift logic (extensions)
                            let initialViewController = UIStoryboard.initialViewController(for: .login)
                            self.view.window?.rootViewController = initialViewController
                            self.view.window?.makeKeyAndVisible()
                        })
                        
                        alert.addAction(action)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            
        }) { (error) in
            self.showAlert(title: "Error", description: error.getMessage())
            DispatchQueue.main.async {
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
}

