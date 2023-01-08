//
//  PassengersViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/11/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import CircleLabel

class PassengersViewController: UIViewController{
    
    //MARK: - Variables
    @IBOutlet weak var adultAgeLabel: UILabel!
    @IBOutlet weak var childrenAgeLabel: UILabel!
    @IBOutlet weak var infantAgeLabel: UILabel!
    
    @IBOutlet weak var adultTextField: UITextField!
    @IBOutlet weak var childrenTextField: UITextField!
    @IBOutlet weak var infantTextField: UITextField!
    
    @IBOutlet weak var adultNumber: CircleLabel!
    @IBOutlet weak var childrenNumber: CircleLabel!
    @IBOutlet weak var infantNumber: CircleLabel!
    
    @IBOutlet weak var adultStepper: UIStepper!
    @IBOutlet weak var childrenStepper: UIStepper!
    @IBOutlet weak var infantSteper: UIStepper!
    
    //Variable travellers Text Field from Search Flight Controller
    var adultValue: Int = 2
    var childrenValue: Int = 0
    var infantValue: Int = 0
    
    //Delegate Protocol to fetch airport user input
    weak var delegate: PassengersForDataEnteredDelegate?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    self.adultStepper.maximumValue = 7
    self.adultStepper.minimumValue = 1
    self.adultStepper.value = Double(self.adultValue)
    self.adultNumber.text = "\(self.adultValue)"
        
    self.childrenStepper.maximumValue = 7
    self.childrenStepper.minimumValue = 0
    self.childrenStepper.value = Double(self.childrenValue)
    self.childrenNumber.text = "\(self.childrenValue)"
        
    self.infantSteper.maximumValue = 7
    self.infantSteper.minimumValue = 0
    self.infantSteper.value = Double(self.infantValue)
    self.infantNumber.text = "\(self.infantValue)"
        
    //Draw underline
    self.adultTextField.underlined()
    self.childrenTextField.underlined()
    self.infantTextField.underlined()
        
    }
    
    @IBAction func adultSetValue(_ sender: UIStepper) {
        
        let stepperValue = Int(sender.value)
        self.adultNumber.text = "\(stepperValue)"
    }
    
    
    @IBAction func chldrenSetValue(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        self.childrenNumber.text = "\(stepperValue)"
        
    }
    
    @IBAction func infantSetValue(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        self.infantNumber.text = "\(stepperValue)"
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        let adultNumber = Int(self.adultStepper.value)
        let childrenNumber = Int(self.childrenStepper.value)
        let infantNumber = Int(self.infantSteper.value)
        
        delegate?.userDidEnterPassengersInfo(adults: adultNumber, child: childrenNumber, infant: infantNumber)
        
    }
    
    
}
