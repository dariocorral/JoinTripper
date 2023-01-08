//
//  FlightsPoolViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 10/11/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import AviasalesSDK


class FlightsPoolViewController: UITableViewController {
    
    
    var flightTickets = [JRSDKTicket]()
    //Variables to pass to FlightsDetailViewController
    var flights = [JRSDKFlight]()
    var searchId: String? = ""
    var proposalsArray = [JRSDKProposal]()
    
    func minutesToTextfieldTime(minutes: Int) -> (String){
        
        let hours = (minutes / 60)
        let minutesB = minutes % 60
        
      return ("\(hours)h \(minutesB)m")
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Remove flights
        self.flights.removeAll()
        //Remove proposal
        self.proposalsArray.removeAll()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        self.tableView.allowsMultipleSelection = false
        
        //Gradient Background color for tableView
        self.setTableViewBackgroundGradient(sender: self, ColorHex.hexStringToUIColor(hex: "#F2B2AF"), ColorHex.hexStringToUIColor(hex: "#B68CE1"))
        
        print("Flight Ticket Filtered Count: \(flightTickets.count)")
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.flightTickets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Cell Definition
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlightsPoolCell") as! FlightsPoolCell
        
        //Background color table view clear
        cell.backgroundColor = UIColor.clear
        
        //IndexPath
        let ticket = self.flightTickets[indexPath.row]
        
        guard let bestPrice = ticket.proposals[0] as? JRSDKProposal
            else {
                print("Impossible to convert to JRSDKProposal")
                return cell
        }
        
        
        guard let flightSegments =
            ticket.flightSegments.array as? [JRSDKFlightSegment] else {
                print("Impossible to covert to JRSDKFlightSegment")
                return cell
        }
        
        //Variables to add to Cells
        var gate = String()
        let gateArray = bestPrice.gate.label.components(separatedBy: " ")
        
        if gateArray.count >= 3 {
            
            gate = "\(gateArray[0]) \(gateArray[1])"
            
        } else {
            gate = bestPrice.gate.label
        }
        
        var flights = 0
        //Sum up all flights
        if flightSegments.count == 2 {
            flights = (flightSegments[0].flights.count) + (flightSegments[1].flights.count)
            } else {
            flights = (flightSegments[0].flights.count)
        }
        
        let exactDate = NSDate(timeIntervalSince1970: TimeInterval(truncating: flightSegments[0].departureDateTimestamp))
        var dateComponent = DateComponents()
        dateComponent.hour = -1
        let correctedDate = Calendar.current.date(byAdding: dateComponent, to: exactDate as Date)
        
        let dateFormatt = DateFormatter()
        dateFormatt.dateStyle = DateFormatter.Style.medium
        dateFormatt.timeStyle = DateFormatter.Style.short
        dateFormatt.setLocalizedDateFormatFromTemplate("dd,MMM,yy HH:mm")
        let departureDateTime = dateFormatt.string(from: correctedDate ?? exactDate as Date)
        
        
        let duration = ticket.totalDuration.intValue
        let durationFormatted = self.minutesToTextfieldTime(minutes: duration)
        
        var mainAirline = String()
        let mainAirlineArray = ticket.mainAirline.name.components(separatedBy: " ")
        
        if mainAirlineArray.count >= 3 {
            
            mainAirline = "\(mainAirlineArray[0]) \(mainAirlineArray[1])"
            
        } else {
            mainAirline = ticket.mainAirline.name
        }
        
        let price = bestPrice.price.priceInUserCurrency()
        
        //Currency formatter
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        guard let priceLocalCurrency = formatter.string(from: price) else {return cell}
        
        cell.price.text =  "💸 \(priceLocalCurrency)"
        
        cell.mainAirline.text = "\(mainAirline) - \(gate)"
        cell.duration.text = "🛫 \(departureDateTime) "
        cell.flights.text = "✈️ \(flights) ⏳ \(durationFormatted)"
        
        return cell
    }
    
    //MARK: - Prepare data to callback along segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.toFlightsDetail, let flightsDetailViewController = segue.destination as? FlightsDetailViewController  {
            flightsDetailViewController.flights = self.flights
            flightsDetailViewController.proposalsArray = self.proposalsArray
            flightsDetailViewController.searchId = self.searchId
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let selectedTicket = self.flightTickets[indexPath.row]
        
        let group = DispatchGroup()
        let queueArray = DispatchQueue(label: "array")
            
        group.enter()
        
        queueArray.async(group: group){
            guard let flightSegments =
                selectedTicket.flightSegments.array as? [JRSDKFlightSegment] else {
                    print("Impossible to covert to JRSDKFlightSegment")
                    return
            }
            
            guard let proposals = selectedTicket.proposals.array as? [JRSDKProposal] else {
                print("Impossible to convert to JRSDKProposal")
                return
            }
        
            //Add only the first element (Best Price)
            self.proposalsArray.append(proposals[0])
            
            
            if flightSegments.count == 2 {
            
                guard let firstFlightSegment = flightSegments[0].flights.array as? [JRSDKFlight], let secondFlightSegment = flightSegments[1].flights.array as? [JRSDKFlight] else {
                    print ("Impossible to convert to JRSDKFlight the selected ticket")
                    return
                    }
                
                    for flights in firstFlightSegment {
                        self.flights.append(flights)
                    }
                
                    for flights in secondFlightSegment {
                        self.flights.append(flights)
                    }
            } else {
               
                guard let firstFlightSegment = flightSegments[0].flights.array as? [JRSDKFlight] else {
                    print ("Impossible to convert to JRSDKFlight the selected ticket")
                    return
                    }
                for flights in firstFlightSegment {
                    self.flights.append(flights)
                    }
                
            }
            
            group.leave()
            
        }
        
        group.notify(queue: .main) {
            self.performSegue(withIdentifier: Constants.Segue.toFlightsDetail, sender: self)
            
        }
    }
    
}

