//
//  SearchFlightViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import AviasalesSDK
import SwiftSpinner

//MARK: - Protocols for Data Delegate
protocol DepartureAirportForDataEnteredDelegate: class {
    func userDidEnterDepartureAirportRequestInfo(airport: String )
}

protocol ArrivalAirportForDataEnteredDelegate: class {
    func userDidEnterArrivalAirportRequestInfo(airport: String )
}

protocol PassengersForDataEnteredDelegate: class {
    func userDidEnterPassengersInfo(adults: Int, child: Int, infant: Int)
}


class SearchFlightViewController: UIViewController, JRSDKSearchPerformerDelegate, UITextFieldDelegate, DepartureAirportForDataEnteredDelegate, ArrivalAirportForDataEnteredDelegate, PassengersForDataEnteredDelegate, UIToolbarDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    
   
    //MARK: - Variables
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var selectDateOneLabel: UILabel!
    @IBOutlet weak var selectDateTwoLabel: UILabel!
    @IBOutlet weak var travellersLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    
   
    @IBOutlet weak var departureTextField: UITextField!
    @IBOutlet weak var arrivalTextField: UITextField!
    @IBOutlet weak var departureDateTextField: UITextField!
    @IBOutlet weak var returnDateTextField: UITextField!
    @IBOutlet weak var travellersTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    
    @IBOutlet weak var switchReturnTrip: UISwitch!

    
    //Flight Segment Result to transfer next storyboards
    var flightTickets = [JRSDKTicket]()
    //Search Id to transfer
    var searchId: String? = ""
    
    //Search Flight Button
    @IBOutlet weak var searchFlightButton: UIButton!
    
    //Properties to transfer to Passengers View Controller
    var adultValue: Int {
        guard let adultText =
            self.travellersTextField.text?.components(separatedBy: " ") else {return 2}
        let adultInt = Int(adultText[0].description)
        return adultInt ?? 2
    }
    
    var childrenValue: Int {
        guard let childrenText =
            self.travellersTextField.text?.components(separatedBy: " ") else {return 0}
        let childrenInt = Int(childrenText[2].description)
        return childrenInt ?? 0
    }
    
    var infantValue: Int {
        guard let infantText =
            self.travellersTextField.text?.components(separatedBy: " ") else {return 0}
        let infantInt = Int(infantText[4].description)
        return infantInt ?? 0
    }
    
    //Stack Hide View
    @IBOutlet weak var returnDateView: UIStackView!
    //Switch Button
    @IBAction func returnSwitchClicked(_ sender: UISwitch) {
        
        if sender.isOn{
            self.returnDateView.fadeIn()
        }else{
            self.returnDateView.fadeOut()
        }
    }
    
    //date picker
    var datePickerViewDeparture: UIDatePicker = UIDatePicker()
    var datePickerViewReturn: UIDatePicker = UIDatePicker()
    var toolBarDatePickerDeparture:UIToolbar = UIToolbar()
    var toolBarDatePickerReturn: UIToolbar = UIToolbar()
    
    //class picker
    //picker Amount values
    let pickerClass = UIPickerView()
    var selectedRowClass = 0
    
    
    //MARK: - DatePickerViewDeparture
    func addDatePickerViewToDepartureTextField() {
        
        datePickerViewDeparture.datePickerMode = UIDatePicker.Mode.date
        datePickerViewDeparture.locale = Locale(identifier: "en")
        datePickerViewDeparture.timeZone = TimeZone.current
        
        //DatePicker config
        let currentDate = NSDate()
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let dateComponents = NSDateComponents()
        dateComponents.day = 0
        let minDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        dateComponents.year = 1
        let maxDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        
        datePickerViewDeparture.minimumDate = minDate
        datePickerViewDeparture.maximumDate = maxDate
        
        toolBarDatePickerDeparture.barStyle = UIBarStyle.default
        toolBarDatePickerDeparture.isTranslucent = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed(sender:)))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBarDatePickerDeparture.setItems([flexibleSpace,doneButton], animated: true)
        toolBarDatePickerDeparture.isUserInteractionEnabled = true
        toolBarDatePickerDeparture.sizeToFit()
        
        //DepartureDateTextField
        self.departureDateTextField.inputAccessoryView = toolBarDatePickerDeparture
        self.departureDateTextField.inputView = datePickerViewDeparture
        
    }
    
    //MARK: - DatePickerViewReturn
    func addDatePickerViewToReturnTextField() {
        
        datePickerViewReturn.datePickerMode = UIDatePicker.Mode.date
        datePickerViewReturn.locale = Locale(identifier: "en")
        datePickerViewReturn.timeZone = TimeZone.current
        
        //DatePicker config
        let currentDate = NSDate()
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let dateComponents = NSDateComponents()
        dateComponents.day = 0
        let minDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        dateComponents.year = 1
        let maxDate = calendar.date(byAdding: dateComponents as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        
        datePickerViewReturn.minimumDate = minDate
        datePickerViewReturn.maximumDate = maxDate
        
        toolBarDatePickerReturn.barStyle = UIBarStyle.default
        toolBarDatePickerReturn.isTranslucent = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed(sender:)))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBarDatePickerReturn.setItems([flexibleSpace,doneButton], animated: true)
        toolBarDatePickerReturn.isUserInteractionEnabled = true
        toolBarDatePickerReturn.sizeToFit()
        
        //DepartureDateTextField
        self.returnDateTextField.inputAccessoryView = toolBarDatePickerReturn
        self.returnDateTextField.inputView = datePickerViewReturn
        
    }
    
    @objc func datePickerDepartureValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE,dd MMM yy")
        dateFormatter.timeZone = TimeZone.current
        
        self.departureDateTextField.text = dateFormatter.string(from: sender.date)
        
    }
    @objc func datePickerReturnValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE,dd MMM yy")
        dateFormatter.timeZone = TimeZone.current
        
        self.returnDateTextField.text = dateFormatter.string(from: sender.date)
    
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        
        self.departureDateTextField.resignFirstResponder()
        self.returnDateTextField.resignFirstResponder()
    }
    
    //MARK: - Method to send value of datePickerView TextFields
    @IBAction func dateTextFieldEditing(_ sender: UITextField) {
        
        if (sender == self.departureDateTextField)   {
            
            datePickerViewDeparture.addTarget(self, action: #selector(self.datePickerDepartureValueChanged), for: .valueChanged)
            
            sender.inputView = datePickerViewDeparture
            
            //Method to assure return date is lower than departure date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            dateFormatter.locale = Locale(identifier: "en")
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE,dd MMM yy")
            dateFormatter.timeZone = TimeZone.current
            
            guard let departureStringDate = self.departureDateTextField.text,let returnStringDate = self.returnDateTextField.text,let departureDate = dateFormatter.date(from: departureStringDate), let returnDate = dateFormatter.date(from: returnStringDate) else {
                return}
            
            if returnDate < departureDate {
                
                self.returnDateTextField.text = departureStringDate
            }
            
        }
        else if (sender == self.returnDateTextField) {
            datePickerViewReturn.addTarget(self, action: #selector(self.datePickerReturnValueChanged), for: .valueChanged)
            
            sender.inputView = datePickerViewReturn
            
            //Method to assure return date is lower than departure date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.none
            dateFormatter.locale = Locale(identifier: "en")
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE,dd MMM yy")
            dateFormatter.timeZone = TimeZone.current
            
            guard let departureStringDate = self.departureDateTextField.text,let returnStringDate = self.returnDateTextField.text,let departureDate = dateFormatter.date(from: departureStringDate), let returnDate = dateFormatter.date(from: returnStringDate) else {
                return}
            
            if returnDate < departureDate {
                
                self.returnDateTextField.text = departureStringDate
            }
            
        }
        
    }
    
    //MARK:- Picker View Class Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - UIPickerView common components for Class Pickerview
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == self.pickerClass {
            
            return TravelClass.allCases.count
        }
      
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == self.pickerClass {
            
            let travelClass = TravelClass.allCases[row]
            
            switch travelClass {
                case .economy:  return "Economy"
                case .business: return "Business"
                case .first: return "First"
                case .premiumEconomy: return "Premiun Economy"
            }
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.pickerClass {
            
            selectedRowClass = row
        }
    }
    
    //Done Button config -toolbar- TimeFrame
    func doneButtonClassPickerView(){
        
        let pickerViewClass = pickerClass
        pickerViewClass.backgroundColor = .clear
        pickerViewClass.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePickerClass))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.classTextField.inputView = pickerViewClass
        self.classTextField.inputAccessoryView = toolBar
    }
    
    
    @objc func donePickerClass() {
        
        let rowSelectedDescription = self.selectedRowClass.description
        
        switch rowSelectedDescription {
        case "0":
            self.classTextField.text = "Economy"
        case "1":
            self.classTextField.text = "Business"
        case "2":
            self.classTextField.text = "First"
        case "3":
            self.classTextField.text = "Premium Economy"
        default:
            self.classTextField.text = "Economy"
        }
        
        self.classTextField.resignFirstResponder()
    }
    
    // MARK: Methods to callback to this view Departure/Arrival/Passengers airports value selected
    func userDidEnterDepartureAirportRequestInfo(airport: String){
        self.departureTextField.text = airport
        navigationController?.popViewController(animated: true)
    }
    
    func userDidEnterArrivalAirportRequestInfo(airport: String){
        self.arrivalTextField.text = airport
        navigationController?.popViewController(animated: true)
    }
    
    func userDidEnterPassengersInfo(adults: Int, child: Int, infant: Int) {
        self.travellersTextField.text = "\(adults) Adult \(child) Child \(infant) Infant"
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Prepare data to callback along segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.showAirportsDeparture, let airportsDepartureViewController = segue.destination as? AirportsDepartureViewController  {
            airportsDepartureViewController.delegate = self
        }
        else if segue.identifier == Constants.Segue.showAirportsArrival, let airportsArrivalViewController = segue.destination as? AirportsArrivalViewController {
            airportsArrivalViewController.delegate = self
        }
        else if segue.identifier == Constants.Segue.toPassengers, let passengersViewController = segue.destination as? PassengersViewController {
            passengersViewController.delegate = self
            
            passengersViewController.adultValue = self.adultValue
            passengersViewController.childrenValue = self.childrenValue
            passengersViewController.infantValue = self.infantValue
            
        }
        else if segue.identifier == Constants.Segue.toFlightsPool , let flightsPoolViewController = segue.destination as? FlightsPoolViewController{
            
            flightsPoolViewController.flightTickets = self.flightTickets
            flightsPoolViewController.searchId = self.searchId
        }
    }
    
    //MARK: Function to get flightsTicketsArray
    
    func getFlightTicketsArray (searchResult: JRSDKSearchResult?)  {
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            
            guard let searchResult = searchResult?.tickets else {
                print ("No tickets found")
                return
            }
            guard let searchResultArray = searchResult.array as? [JRSDKTicket] else {
                print("Impossible to covert to JRSDKTicket")
                return
            }
            
            print("Flight Tickets found (No filtered): \(searchResultArray.count)")
            
            for ticket in searchResultArray {
                
                if !ticket.hasOvernightStopover {//&& ticket.isFromTrustedGate {
                
                    self.flightTickets.append(ticket)
                }
            }
            
            group.leave()
            
        }
        
        group.notify(queue: .main) {
            
            return
        }
    }
    
    //MARK:- Protocols JRSDKSearchPerformer Delegate
    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFinishRegularSearch searchInfo: JRSDKSearchInfo!, with result: JRSDKSearchResult!, andMetropolitanResult metropolitanResult: JRSDKSearchResult!) {
        
        self.searchId = result.searchResultInfo.searchID
        
        self.getFlightTicketsArray(searchResult: result)
    }
    
    
    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFailSearchWithError error: Error!) {
        if error != nil {
            print("Error Searching Process: \(error.debugDescription)")
            //Hide swiftspinner
            SwiftSpinner.hide()
            self.showAlert(title: "Error", description: "Server error. Try later")
        }
    }
    
    func searchPerformer(_ searchPerformer: JRSDKSearchPerformer!, didFinalizeSearchWith searchInfo: JRSDKSearchInfo!, error: Error!) {
        if error != nil {
            print("Error Searching Process: \(error.debugDescription)")
            self.showAlert(title: "Error", description: "Server error. Try later")
        } else {
            
            print ("Searching process finished")
            //Hide swiftspinner
            SwiftSpinner.hide()
            //Perform segue
            if self.flightTickets.count != 0 {
            print("Tickets to transfer: \(self.flightTickets.count)")
            self.performSegue(withIdentifier: Constants.Segue.toFlightsPool, sender: self)
            } else {
                showAlert(title: "No flights found", description: "There are no flights for this search")
            }
        }
    }

    
    //MARK: - Search Tickets
    func searchTickets() {
        
        //Swift Spinner load
        SwiftSpinner.show("Searching Flights...")
        SwiftSpinner.show(delay: 50.0, title: "Low Connectivity...")
        
        //Search Builder variable
        let searchInfoBuilder = JRSDKSearchInfoBuilder()
        
        //Search Info Builder Variables
        searchInfoBuilder.adults = UInt(self.adultValue)
        searchInfoBuilder.children = UInt(self.childrenValue)
        searchInfoBuilder.infants = UInt(self.infantValue)
        
        
        let travelClassValue = self.classTextField.text ?? "Economy"
        
        switch travelClassValue {
        case "Econmy":
            searchInfoBuilder.travelClass = .economy
        case "Business":
            searchInfoBuilder.travelClass = .business
        case "First":
            searchInfoBuilder.travelClass = .first
        case "Premium Economy":
            searchInfoBuilder.travelClass = .premiumEconomy
        default:
            searchInfoBuilder.travelClass = .economy
        }
        
        
        let travelSegmentBuilder = JRSDKTravelSegmentBuilder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE,dd MMM yy")
        dateFormatter.timeZone = TimeZone.current
        
        //Departure date
        let currentDate = Date()
        let daysToAdd = 1
        
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let correctedDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        
        let currentDateString = dateFormatter.string(from: correctedDate ?? currentDate)
        
        let departureDateString = self.departureDateTextField.text ?? currentDateString
        let returnDateString = self.returnDateTextField.text ?? currentDateString
        
        guard let departureDate = dateFormatter.date(from: departureDateString),
              let departureDateCorrected = Calendar.current.date(byAdding: dateComponent, to: departureDate) else {
            print("Error converting dates")
            self.showAlert(title: "Error", description: "Server Error. Try later")
            return
        }
        
        travelSegmentBuilder.departureDate = departureDateCorrected
        
        //Airports
        guard let departureAirportText = self.departureTextField.text,
              let departureCode = departureAirportText.components(separatedBy: " ").first else {
                print ("Error: Invalid Departure Code text")
                self.showAlert(title: "Error Departure Airport", description: "Invalid Departure Airport Code. Try again later")
                return
            }
        
        guard let arrivalAirportText = self.arrivalTextField.text,
            let arrivalCode = arrivalAirportText.components(separatedBy: " ").first else {
                print ("Error: Invalid Arrival Code text")
                self.showAlert(title: "Error Arrival Airport", description: "Invalid Arrival Airport Code. Try again later")
                return
                
            }
        
        travelSegmentBuilder.originAirport = AviasalesSDK.sharedInstance().airportsStorage.findAnything(byIATA: departureCode)
        travelSegmentBuilder.destinationAirport = AviasalesSDK.sharedInstance().airportsStorage.findAnything(byIATA: arrivalCode)
        
        guard let travelSegment = travelSegmentBuilder.build() else {
            print("Error building travelSegment")
            self.showAlert(title: "Error", description: "Server Error. Try later")

            return
        }
        //Print Console Summary Flight Search
        print("Summary Flight Search")
        print(" Departure Airport: \(departureCode)")
        print(" Arrival Airport:\(arrivalCode)")
        print(" Departure Date: \(departureDateString)")
        if !self.returnDateView.isHidden {
            print(" Return Date: \(returnDateString)")
        }
        print(" Adults: \(UInt(self.adultValue))")
        print(" Children: \(UInt(self.childrenValue))")
        print(" Infant: \(UInt(self.infantValue))")
        print(" Travel Class: \(travelClassValue)")
        
        //Proceed return flight if choosen
        if self.switchReturnTrip.isOn {
            
            //Create new travel Segment for return
            let travelSegmentBuilderReturn = JRSDKTravelSegmentBuilder()
            
            //Return date conversion
            guard let returnDate = dateFormatter.date(from: returnDateString),
                let returnDateCorrected = Calendar.current.date(byAdding: dateComponent, to: returnDate) else {
                    print("Error converting Return dates")
                    self.showAlert(title: "Error", description: "Server Error. Try later")
                    return
            }
            
            travelSegmentBuilderReturn.departureDate = returnDateCorrected
            
            travelSegmentBuilderReturn.originAirport = AviasalesSDK.sharedInstance().airportsStorage.findAnything(byIATA: arrivalCode)
            travelSegmentBuilderReturn.destinationAirport = AviasalesSDK.sharedInstance().airportsStorage.findAnything(byIATA: departureCode)
            
            searchInfoBuilder.travelSegments = NSOrderedSet(array: [travelSegmentBuilder,travelSegmentBuilderReturn])
            
        } else {
            
            //Build & Execute Search Performer only one way
            searchInfoBuilder.travelSegments = NSOrderedSet(object: travelSegment)
        }
        
        if !searchInfoBuilder.canBuild() {
            
            print ("Error: Search Info Builder cannot build")
        }
        
        let searchInfo: JRSDKSearchInfo? = searchInfoBuilder.build()
        
        let searchPerformer: JRSDKSearchPerformer? = AviasalesSDK.sharedInstance().createSearchPerformer()
        
        searchPerformer?.delegate = self
        searchPerformer?.performSearch(with: searchInfo, includeResultsInEnglish: true)
        
        
    }
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: "Cannot Connect to Server", message: "Check your internet connection", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        //Delegates
        self.departureTextField.delegate = self
        self.arrivalTextField.delegate = self
        self.travellersTextField.delegate = self
        
        //Draw underline
        self.departureTextField.underlined()
        self.arrivalTextField.underlined()
        self.departureDateTextField.underlined()
        self.returnDateTextField.underlined()
        self.travellersTextField.underlined()
        self.classTextField.underlined()
        
        //To control Date Picker variables
        self.addDatePickerViewToDepartureTextField()
        self.addDatePickerViewToReturnTextField()
        
        //To control Class Picker
        //To Control picker amount
        self.pickerClass.delegate = self
        self.pickerClass.dataSource = self
        classTextField.inputView = pickerClass
        doneButtonClassPickerView()
        
        //Hide Returd date view
        self.returnDateView.alpha = 0.0
        self.returnDateView.isHidden = true
        
        //Departure DatePickerView
        self.dateTextFieldEditing(self.departureDateTextField)
        
        //Return DatePickerView
        self.dateTextFieldEditing(self.returnDateTextField)
        
        self.datePickerDepartureValueChanged(sender: datePickerViewDeparture)
        self.datePickerReturnValueChanged(sender: datePickerViewReturn)
        
        //Adjust Text Label
        self.fromLabel.adjustsFontSizeToFitWidth = true
        let fromLabelHeight = fromLabel.optimalHeight
        fromLabel.frame = CGRect(x: fromLabel.frame.origin.x, y: fromLabel.frame.origin.y, width: fromLabel.frame.width, height: fromLabelHeight)
        
        self.toLabel.adjustsFontSizeToFitWidth = true
        let toLabelHeight = toLabel.optimalHeight
        toLabel.frame = CGRect(x: toLabel.frame.origin.x, y: toLabel.frame.origin.y, width: toLabel.frame.width, height: toLabelHeight)
        
        self.selectDateOneLabel.adjustsFontSizeToFitWidth = true
        let selectDateOneLabelHeight = selectDateOneLabel.optimalHeight
        selectDateOneLabel.frame = CGRect(x: selectDateOneLabel.frame.origin.x, y: selectDateOneLabel.frame.origin.y, width: selectDateOneLabel.frame.width, height: selectDateOneLabelHeight)
        
        self.selectDateTwoLabel.adjustsFontSizeToFitWidth = true
        let selectDateTwoLabelHeight = selectDateTwoLabel.optimalHeight
        selectDateTwoLabel.frame = CGRect(x: selectDateTwoLabel.frame.origin.x, y: selectDateTwoLabel.frame.origin.y, width: selectDateTwoLabel.frame.width, height: selectDateTwoLabelHeight)
        
        self.travellersLabel.adjustsFontSizeToFitWidth = true
        let travellersLabelHeight = travellersLabel.optimalHeight
        travellersLabel.frame = CGRect(x: travellersLabel.frame.origin.x, y: travellersLabel.frame.origin.y, width: travellersLabel.frame.width, height: travellersLabelHeight)
        
        self.classLabel.adjustsFontSizeToFitWidth = true
        let classLabelHeight = classLabel.optimalHeight
        classLabel.frame = CGRect(x: classLabel.frame.origin.x, y: classLabel.frame.origin.y, width: classLabel.frame.width, height: classLabelHeight)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Remove flights
        self.flightTickets.removeAll()
        self.searchId = ""
        
    }
    
    //MARK: - Switch Departure-Arrival airports
    @IBAction func switchAirports (sender: UIButton){
        if (self.departureTextField.text != "Departure Airport") && (self.arrivalTextField.text != "Arrival Airport") {
            guard let departureAirport = self.departureTextField.text,
                let arrivalAirport = self.arrivalTextField.text else {return}
            
            self.departureTextField.text = arrivalAirport
            self.arrivalTextField.text = departureAirport
            
        }
        
    }
    
    //MARK:- TextField Delegate methods
    //Not activate keyboard when editing these fields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        self.view.endEditing(true)
        
        return false
    }
    
    //Perform segue according to textfield selected
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        if (textField == departureTextField)  {
            self.performSegue(withIdentifier: Constants.Segue.showAirportsDeparture, sender: self)
            
        }
        else if (textField == arrivalTextField) {
            self.performSegue(withIdentifier: Constants.Segue.showAirportsArrival, sender: self)
        }
        else if (textField == travellersTextField){
            self.performSegue(withIdentifier: Constants.Segue.toPassengers, sender: self)
        }
        
        return false
    }
    
    //MARK:- Search Flight Process
    @IBAction func searchFlightButtonTapped(_ sender: UIButton) {
        
        if (self.departureTextField.text == "Departure Airport") && (self.arrivalTextField.text == "Arrival Airport") {
            
            //Animation failed request
            self.shakeAnimationButton(for: self.searchFlightButton)
            
            //Alert Present
            self.showAlert(title: "Blank Airports",description:"You must choose  Departure & Arrival Airport")
        
        } else if (self.arrivalTextField.text == "Arrival Airport") {
            
            //Animation failed request
            self.shakeAnimationButton(for: self.searchFlightButton)
            
            //Alert Present
            self.showAlert(title: "Blank Arrival Airport",description:"You must choose Arrival Airport")
        } else if (self.departureTextField.text == "Departure Airport") {
            
            //Animation failed request
            self.shakeAnimationButton(for: self.searchFlightButton)
            
            //Alert Present
            self.showAlert(title: "Blank Departure Airport",description:"You must choose  Departure Airport")
            
        } else if (self.departureTextField.text == self.arrivalTextField.text) {
            
            //Animation failed request
            self.shakeAnimationButton(for: self.searchFlightButton)
            
            //Alert Present
            self.showAlert(title: "Airports Error",description:"Departure and Arrival Airport can not be identical")
            
        } else {
          self.searchTickets()
        }
    }
}

