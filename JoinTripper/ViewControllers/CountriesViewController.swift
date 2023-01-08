//
//  CountriesViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import CoreData


class CountriesViewController: UITableViewController {
    
    //MARK: - Countries View Controller variables
    
    let dataCountries = DataAPI()
    var countries: [NSManagedObject] = []
    var filteredCountries: [NSManagedObject] = []
    let searchController = UISearchController(searchResultsController: nil)
    weak var delegate: CountriesDataEnteredDelegate?
    weak var delegateModifyProfile: CountriesDataEnteredModifyProfileDelegate?
    
    //Varibale Country check mark
    var countrySelected = String()
    
    
    //MARK: - Define Search Bar propierties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = false
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Countries"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = ColorHex.hexStringToUIColor(hex: "#F2B2AF")
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        //Hide search bar when loading view
        //        tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: false)
        
        //Change color text search bar and placeholder
        // SearchBar text
        let textFieldInsideUISearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = ColorHex.hexStringToUIColor(hex: "#526CA0")
        
        // SearchBar placeholder
        let textFieldInsideUISearchBarLabel = textFieldInsideUISearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideUISearchBarLabel?.textColor = ColorHex.hexStringToUIColor(hex: "#526CA0")
        
        //No division line search bar
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = ColorHex.hexStringToUIColor(hex: "#F2B2AF").cgColor
        searchController.searchBar.tintColor = ColorHex.hexStringToUIColor(hex: "#526CA0")
        
        // Call sizeToFit() on the search bar so it fits nicely in the UIView
        searchController.searchBar.sizeToFit()
        // For some reason, the search bar will extend outside the view to the left after calling sizeToFit. This next line corrects this.
        searchController.searchBar.frame.size.width = self.view.frame.size.width
        
        //Gradient Background color for tableView
        self.setTableViewBackgroundGradient(sender: self, ColorHex.hexStringToUIColor(hex: "#F2B2AF"), ColorHex.hexStringToUIColor(hex: "#B68CE1"))
        
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
            NSFetchRequest<NSManagedObject>(entityName: "Countries")
        
        //Ordenamos el nombre de las divisas alfabéticamente
        let sortByName = NSSortDescriptor(key: #keyPath(Countries.name),
                                          ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        do {
            countries = try managedContext.fetch(fetchRequest)
            
            //Si no hay información cargamos la info en Core Data desde el file JSON
            if 0 ..< 24 ~= countries.count {
                
                dataCountries.loadJSONCountriesData()
                
                //Ordenamos el símbolo de las divisas alfabéticamente
                let sortByName = NSSortDescriptor(key: #keyPath(Countries.name),
                                                  ascending: true)
                fetchRequest.sortDescriptors = [sortByName]
                countries = try managedContext.fetch(fetchRequest)
            }
            
        } catch let error as NSError {
            print("Could not fetch Countries Data: \(error), \(error.userInfo)")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCountries.count
        }
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create an instance of UITableViewCell, with default appearance
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountriesCell", for: indexPath) as! CountriesCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the tableview
        
        if searchController.isActive && searchController.searchBar.text != "" {
            let country = filteredCountries[indexPath.row]
            cell.code?.text = country.value(forKeyPath: "code") as? String
            cell.name?.text = country.value(forKeyPath: "name") as? String
            
            //Check Mark selected languages values previously
            if let textCell = cell.name?.text  {
                
                if self.countrySelected == textCell {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            
            return cell
            
        }else{
            
            let country = countries[indexPath.row]
            cell.code?.text = country.value(forKeyPath: "code") as? String
            cell.name?.text = country.value(forKeyPath: "name") as? String
            
            //Check Mark selected languages values previously
            if let textCell = cell.name?.text  {
                
                if self.countrySelected == textCell {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            
            return cell
        }
    }
    
    //MARK: - Search Bar function for filtering results
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Countries")
        
        //Ordenamos el nombre de los países alfabéticamente
        let sortByName = NSSortDescriptor(key: #keyPath(Countries.name),
                                          ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@ OR code contains[cd] %@", searchText.lowercased(), searchText.uppercased())
        do {
            filteredCountries = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            
            print("Could not fetch Filtered Countries Data: \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Select and send to ConverterViewController currencies selected
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? CountriesCell {
            if cell.isSelected {
                cell.accessoryType = .none
            }
            if let text = cell.name?.text  {
                print("Country selected: \(text)")
                
                //Callback function
                delegate?.userDidEnterCountriesInfo(country: text)
                delegateModifyProfile?.userDidEnterCountriesInfo(country: text)
                
            }
        }
    }
}

extension CountriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
