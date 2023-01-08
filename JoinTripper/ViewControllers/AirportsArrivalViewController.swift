//
//  AirportsArrivalViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 18/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//


import UIKit
import CoreData
import CoreLocation



class AirportsArrivalViewController: UITableViewController, CLLocationManagerDelegate {
    
    
    //MARK: - Airports View Controller variables
    let dataAirports = DataAPI()
    var airports: [NSManagedObject] = []
    var filteredAirports: [NSManagedObject] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    //Delegate Protocol to fetch airport user input
    weak var delegate: ArrivalAirportForDataEnteredDelegate?
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            
        }
    }
    
    //MARK: Number formatter
    let numberFormatterAmount: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = Locale.current
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 0
        return nf
    }()
    
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
            
            print("\(airports.count) airports located")
            
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
    
    //MARK: - Load Airports data
    func loadAirportsData() {
        
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
            
        } catch let error as NSError {
            print("Could not fetch Airports Data: \(error), \(error.userInfo)")
        }
        
    }
    
    //MARK: - Define Search Bar propierties
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        self.tableView.allowsMultipleSelection = false
        
        //Gradient Background color for tableView
        self.setTableViewBackgroundGradient(sender: self, ColorHex.hexStringToUIColor(hex: "#F2B2AF"), ColorHex.hexStringToUIColor(hex: "#B68CE1"))
        
        self.loadAirportsData()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Airports"
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
        
    }
    
    //MARK: - Call ViewDidAppear to show first pop alert
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Check data airports
        self.preLoadAirportsData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Private instance methods
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredAirports.count
        }
        return airports.count
    }
    
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // Create an instance of UITableViewCell, with default appearance
        let cell = tableView.dequeueReusableCell(withIdentifier: "AirportsCell", for: indexPath) as! AirportsCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the tableview
        
        
        if searchController.isActive && searchController.searchBar.text != "" {
            let airport = filteredAirports[indexPath.row]
            guard let code = airport.value(forKeyPath: "code") as? String,
                let name = airport.value(forKeyPath: "name") as? String,
                let distance = airport.value(forKeyPath: "distance") as? Double else {return cell}
            
            //units formatter
            let formatter = MeasurementFormatter()
            formatter.unitOptions = MeasurementFormatter.UnitOptions.naturalScale
            formatter.unitStyle = .medium
            let locale = Locale.current.identifier
            formatter.locale = Locale(identifier: locale)
            let distanceMeters = Measurement(value: distance,unit: UnitLength.meters)
            let distanceKm =  distanceMeters.converted(to: UnitLength.kilometers)
            let mFormatter = MeasurementFormatter()
            mFormatter.numberFormatter = numberFormatterAmount
            
            cell.code.text = code
            
            //Remove "airport" from name
            var fullname = name.components(separatedBy: " ")
            
            if fullname.last == "Airport" {
                fullname.removeLast()
            }
            
            //Remove "international" from name
            if fullname.last == "International" {
                fullname.removeLast()
            }
            
            cell.name.text = fullname.joined(separator: " ")
            
            cell.distance.text = mFormatter.string(from: distanceKm)
            return cell
            
        }else{
            
            let airport = airports[indexPath.row]
            guard let code = airport.value(forKeyPath: "code") as? String,
                let name = airport.value(forKeyPath: "name") as? String,
                let distance = airport.value(forKeyPath: "distance") as? Double else {return cell}
            cell.code.text = code
            
            //Remove "airport" from name
            var fullname = name.components(separatedBy: " ")
            
            if fullname.last == "Airport" {
                fullname.removeLast()
            }
            
            //Remove "international" from name
            if fullname.last == "International" {
                fullname.removeLast()
            }
            
            cell.name.text = fullname.joined(separator: " ")
            
            //units formatter
            let formatter = MeasurementFormatter()
            formatter.unitOptions = MeasurementFormatter.UnitOptions.naturalScale
            formatter.unitStyle = .medium
            let locale = Locale.current.identifier
            formatter.locale = Locale(identifier: locale)
            let distanceMeters = Measurement(value: distance,unit: UnitLength.meters)
            let distanceKm =  distanceMeters.converted(to: UnitLength.kilometers)
            let mFormatter = MeasurementFormatter()
            mFormatter.numberFormatter = numberFormatterAmount
            
            cell.distance.text = mFormatter.string(from: distanceKm)
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
            NSFetchRequest<NSManagedObject>(entityName: "Airports")
        
        //Ordenamos el símbolo de las divisas alfabéticamente
        let sortByCode = NSSortDescriptor(key: #keyPath(Airports.code),
                                          ascending: true)
        fetchRequest.sortDescriptors = [sortByCode]
        fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@ OR code contains[cd] %@", searchText.lowercased(), searchText.uppercased())
        do {
            filteredAirports = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            
            print("Could not fetch Filtered Airports Data: \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Select and send to ConverterViewController currencies selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? AirportsCell {
            if cell.isSelected {
                cell.accessoryType = .none
            }
            if let text = cell.code?.text, let detailText = cell.name?.text {
                
                print("Airport Arrival selected: \(text) \(detailText)")
                
                //Remove first word airport
                var fullNameArray = detailText.components(separatedBy: " ")
                
                if fullNameArray.count > 1 {
                    fullNameArray.removeFirst()
                }
                let nameToChange = fullNameArray.joined(separator: " ")
                
                //Remove "-" words
                var nameArray = nameToChange.components(separatedBy: "-")
                
                if nameArray.count > 1{
                    nameArray.removeLast()
                }
                let nameToShow = nameArray.joined(separator: " ")
                
                let textToShow = text + " " + nameToShow
                
                delegate?.userDidEnterArrivalAirportRequestInfo(airport: textToShow)
            }
        }
    }
}

//MARK: - Extension Currencies Controller for filtering results
extension AirportsArrivalViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}



