//
//  LanguagesViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import CoreData


class LanguagesViewController: UITableViewController {
    
    //MARK: - Languages View Controller variables
    let dataLanguages = DataAPI()
    var languages: [NSManagedObject] = []
    weak var delegate: LanguagesDataEnteredDelegate?
    weak var delegateModifyProfile: LanguagesDataEnteredModifyProfileDelegate?
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    var selectedTextLabels = [IndexPath: String]()
    
    //Languages variable from modify profile
    var languagesArray = [String]()
    
    //MARK: - Define Search Bar propierties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gradient Background color for tableView
        self.setTableViewBackgroundGradient(sender: self, ColorHex.hexStringToUIColor(hex: "#F2B2AF"), ColorHex.hexStringToUIColor(hex: "#B68CE1"))
        
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.tableHeaderView = headerView
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.separatorStyle = .singleLine
        
        // Get the height of the status bar and set cell height automatically
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    //MARK: - Call ViewDidAppear to show first pop alert
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    //MARK: - Prepare Currency data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Languages")
        
        //Ordenamos el símbolo de las lenguas alfabeticamente
        let sortByCode = NSSortDescriptor(key: #keyPath(Languages.code), ascending: true)
        fetchRequest.sortDescriptors = [sortByCode]
        
        do {
            languages = try managedContext.fetch(fetchRequest)
            
            //Si no hay información cargamos la info en Core Data desde el file JSON
            if 0 ..< 19 ~= languages.count {
                
                dataLanguages.loadJSONLanguagesData()
                
                //Ordenamos el símbolo de las divisas alfabéticamente
                let sortByCode = NSSortDescriptor(key: #keyPath(Languages.code),
                                                  ascending: true)
                fetchRequest.sortDescriptors = [sortByCode]
                languages = try managedContext.fetch(fetchRequest)
            }
            
        } catch let error as NSError {
            print("Could not fetch Languages Data: \(error), \(error.userInfo)")
        }
        //Deselect cell if change view
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return languages.count
    }
    
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an instance of UITableViewCell, with default appearance
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguagesCell", for: indexPath) as! LanguagesCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        let language = languages[indexPath.row]
        cell.code?.text = language.value(forKeyPath: "code") as? String
        cell.language?.text = language.value(forKeyPath: "name") as? String
        
        //Check Mark selected languages values previously
        if let textCell = cell.language?.text  {
            
            if languagesArray.contains(textCell) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
        
    }
    
    
    //MARK: - Select and send to ConverterViewController currencies selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? LanguagesCell {
            if cell.isSelected {
                
                cell.selectionStyle = .default
            }
            
            if let text = cell.code?.text, let detailText = cell.language?.text {
                
                selectedTextLabels[indexPath] = detailText
                //Call function to callback info
                let textToShow = text + " " + detailText
                print("Language selected: \(textToShow)")
                self.selectedLabel.text = "Selected \(selectedTextLabels.count)"
                
            }
        }
    }
    
    //Set Maximum Languages to 3
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedRows = tableView.indexPathsForSelectedRows?.filter({ $0.section == indexPath.section }) {
            if selectedRows.count == 3 {
                //Display Alert Maximum Selected languages
                let alert = UIAlertController(title: "Max Languages Reached", message: "Select Max 3 languages", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                return nil
            }
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? LanguagesCell {
            
            cell.accessoryType = .none
            selectedTextLabels[indexPath] = nil
            self.selectedLabel.text = "Selected \(selectedTextLabels.count)"
            
            if let text = cell.code?.text, let detailText = cell.language?.text {
                
                let textToShow = text + " " + detailText
                print("Language DeSelected: \(textToShow)")
                
            }
        }
    }
    
    //MARK: - Selected rows count
    func updateCountTextLabel(){
        if let listLanguages = tableView.indexPathForSelectedRow {
            self.selectedLabel.text = "Selected \(listLanguages.count)"
        }else {
            self.selectedLabel.text = "Selected 0"
        }
    }
    
    //MARK: - Submit languages selected
    @IBAction func resumeButtonTapped(_ sender: UIButton) {
        guard let countSelectedRows = tableView.indexPathsForSelectedRows?.count
            else {return}
        
        if countSelectedRows > 0 {
            guard let indexPaths = tableView.indexPathsForSelectedRows else {return}
            
            var languagesArray = [String]()
            
            for indexPath in indexPaths {
                guard let selectedItem = self.selectedTextLabels[indexPath] else {return}
                languagesArray.append(selectedItem)
            }
            
            let languagesString = languagesArray.joined(separator: ",")
            print("Languages selected: \(languagesString)")
            
            //Callback function
            delegate?.userDidEnterLanguagesInfo(languages: languagesArray)
            delegateModifyProfile?.userDidEnterLanguagesInfo(languages: languagesArray)
            
        }
    }
}


