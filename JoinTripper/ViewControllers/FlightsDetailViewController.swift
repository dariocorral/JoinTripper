//
//  FlightsDetailViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import AviasalesSDK
import SafariServices
import WebBrowser
import FirebaseAuth



class FlightsDetailViewController: UITableViewController {
    
    var flights = [JRSDKFlight]()
    var proposalsArray = [JRSDKProposal]()
    var searchId: String? = ""
    
    @IBOutlet weak var addFlightButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Search Id: \(searchId ?? "Not found searchID")")
        print("Best price Gate: \(proposalsArray[0].gate.label)")
        
        let bestPrice = self.proposalsArray[0].price.priceInUserCurrency()
        
        //Currency formatter
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        guard let priceLocalCurrency = formatter.string(from: bestPrice) else {
            print("Error formatting currency price")
            return }
        
        let buyButtonTittle = "Buy " + "\(priceLocalCurrency)"
        
        self.buyButton.setTitle(buyButtonTittle, for: .normal )
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        self.tableView.allowsMultipleSelection = false
        
        //Gradient Background color for tableView
        self.setTableViewBackgroundGradient(sender: self, ColorHex.hexStringToUIColor(hex: "#F2B2AF"), ColorHex.hexStringToUIColor(hex: "#B68CE1"))
        
        for flight in flights {
            
            print ("Flight added: \(flight.number)")
        }
    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.flights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Cell Definition
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlightDetailCell") as! FlightDetailCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        //IndexPath
        let flight = self.flights[indexPath.row]
        
        let flightNumber = flight.number
        let airlineCode = flight.airline.iata
        let flightCode = "\(airlineCode)-\(flightNumber)"
        
        let airline = flight.airline.name
        
        //Date Formatter
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = DateFormatter.Style.medium
        dateFormatt.timeStyle = DateFormatter.Style.short
        dateFormatt.timeZone = TimeZone.current
        dateFormatt.locale = Locale(identifier: "en")
        dateFormatt.setLocalizedDateFormatFromTemplate("EEE,dd MMM yy HH:mm")
        
        var dateComponent = DateComponents()
        dateComponent.hour = -1
        let correctedDepartureDate = Calendar.current.date(byAdding: dateComponent, to: flight.departureDate as Date)
        let correctedArrivalDate = Calendar.current.date(byAdding: dateComponent, to: flight.arrivalDate as Date)
        
        let departureDate = dateFormatt.string(from: correctedDepartureDate ?? flight.departureDate as Date)
        let arrivalDate = dateFormatt.string(from: correctedArrivalDate ?? flight.arrivalDate as Date)
        
        let departureAirport = flight.originAirport.iata
        let arrivalAirport = flight.destinationAirport.iata
        
        cell.flightCode.text = flightCode
        cell.departureDateTime.text = "🛫 \(departureAirport) \(departureDate)"
        cell.arrivalDateTime.text = "🛬 \(arrivalAirport) \(arrivalDate)"
        
        var mainAirline = String()
        let mainAirlineArray = airline.components(separatedBy: " ")
        
        if mainAirlineArray.count >= 3 {
            
            mainAirline = "\(mainAirlineArray[0]) \(mainAirlineArray[1])"
            
        } else {
            mainAirline = airline
        }
        
        cell.airline.text = mainAirline
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        //let selectedflight = self.flights[indexPath.row]
        
    }
    @IBAction func buyTicketButtonTapped(_ sender: UIButton) {
        
        
        //Perform URL Request for purchasing ticket
        guard let bestPrice = self.proposalsArray.first, let searchID = searchId else {
            print ("Error fetching Proposal/Search ID")
            return
        }
        let gateBrowserPresenter = GateBrowserViewPresenter(ticketProposal: bestPrice, searchID: searchID)
        let webBrowserViewController = BrowserViewController(presenter: gateBrowserPresenter)
        let navigationWebBrowser = WebBrowserViewController.rootNavigationWebBrowser(webBrowser: webBrowserViewController)
        present(navigationWebBrowser, animated: true, completion: nil)
        
    }
    @IBAction func addFlightButtonTapped(_ sender: UIButton) {
        
        guard let indexPath = tableView.indexPathForSelectedRow
            else {print ("I cannot find indexPath of selected row")
                
                //Animation failed request
                let bounds = self.addFlightButton.bounds
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                    self.addFlightButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
                }, completion: nil)
                self.addFlightButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
                
                self.showAlert(title: "No flight selected", description: "Select a flight from the list to search trippers")
                return}
        
        let flight = self.flights[indexPath.row]
        
        print("Flight selected: \(flight)")
        
        //Get a reference to current user logged to FB Database (Mandatory UID)
        guard let firUser = Auth.auth().currentUser else {return}
        
        //Format date
        let departureDate = flight.departureDate
        //Date Formatter
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = DateFormatter.Style.medium
        dateFormatt.timeStyle = DateFormatter.Style.short
        dateFormatt.timeZone = TimeZone.current
        dateFormatt.locale = Locale(identifier: "en")
        dateFormatt.dateFormat = "ddMMyyyy"
        
        var dateComponent = DateComponents()
        dateComponent.hour = -1
        let correctedDepartureDate = Calendar.current.date(byAdding: dateComponent, to: departureDate as Date)
        guard let dateRequest = correctedDepartureDate else {
            print("Not possible to get departure date")
            return
        }
        
        let dateString = dateFormatt.string(from: dateRequest)
        
        //Flight code
        let flightNumber = flight.number
        let airlineCode = flight.airline.iata
        let flightCode = "\(airlineCode)-\(flightNumber)"
        
        let airportCode = "\(flight.originAirport.iata) → \(flight.destinationAirport.iata)"
        let airline = flight.airline.name
        
        var mainAirline = String()
        let mainAirlineArray = airline.components(separatedBy: " ")
        
        if mainAirlineArray.count >= 3 {
            
            mainAirline = "\(mainAirlineArray[0]) \(mainAirlineArray[1])"
            
        } else {
            mainAirline = airline
        }
        
        
        //Build ExRequest Code
        let exRequestId = dateString + "," + flightCode
        
        
        
        //Check user database branck exchange Request
        ExchangeRequestService.checkPointExReqCreated(for: firUser, completion: { (checkBool) in
            
            if checkBool  {
                ExchangeRequestService.create(firUser: firUser, date: dateString, flight: flightCode, airport: airportCode, airline: mainAirline, exRequestId: String(exRequestId))  { (exRequest) in
                    guard exRequest != nil else {
                        
                        let alert = UIAlertController(title: "Exchange Request Already Exists", message: "You can not have 2 equals Exchange Request", preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        //Animation failed request
                        let bounds = self.addFlightButton.bounds
                        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                            self.addFlightButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
                        }, completion: nil)
                        self.addFlightButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
                        
                        return
                    }
                    
                    print("Object ExRequest created:")
                    print("Key - Exchange Request ID: \(exRequest?.key ?? "error Key")")
                    print("Airport Code: \(exRequest?.airport ?? "error Airport")")
                    print("Flight: \(exRequest?.flight ?? "error Currency Owned")")
                    print("Airline: \(exRequest?.airline ?? "error Currency Wanted")")
                    print("Date: \(exRequest?.date ?? "error Date")")
                    
                    
                }
            
                let alert = UIAlertController(title: "Flight Added", message: "You have added \(flightCode) to your flight pool", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ action in
//                    self.navigationController?.popViewController(animated: true)
                    //Come back to root view controller
                    self.navigationController?.popToRootViewController(animated: true)
                    AppStoreReviewManager.requestReviewIfAppropriate()
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
                
            } else {
                
                let alert = UIAlertController(title: "Too many Flights", message: "You have added or modified too many flights. Our service is only for occasionals needs", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ action in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                
                //Animation failed request
                let bounds = self.addFlightButton.bounds
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .allowAnimatedContent, animations: {
                    self.addFlightButton.bounds = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y, width: bounds.size.width + 60, height: bounds.size.height)
                }, completion: nil)
                self.addFlightButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
        })
    }
        
}
    


