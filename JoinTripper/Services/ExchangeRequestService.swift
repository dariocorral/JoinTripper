//
//  ExchangeRequestService.swift
//  JoinTripper
//
//  Created by Dario Corral on 29/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseAuth.FIRUser
import FirebaseDatabase
import CoreData

struct ExchangeRequestService {
    
    static func create ( firUser: FIRUser,  date: String, flight: String, airport: String, airline: String, exRequestId: String, completion: @escaping(ExRequest?) -> Void) {
        
        
        let exReqAttrs = [ "date": date, "flight": flight, "airport": airport, "airline": airline]
        
        let exReqRootAttrs = [firUser.uid: true]
        
        //Check Match Exchange Request
        
        let exRequestIdWanted = (date + "," + flight )
        
        //Check if there is a value with username
        let refToVerify = Database.database().reference().child("exRequests").child(firUser.uid)
        
        refToVerify.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if (snapshot.hasChild(exRequestId) || snapshot.hasChild(exRequestIdWanted)) {
                
                completion(nil)
                
            } else {
                
                //Write to database branch to normalize
                let refNormExRequest = Database.database().reference().child("exRequestsIds").child(exRequestId)
                refNormExRequest.updateChildValues(exReqRootAttrs) { (error, exRqRootAttrs) in
                    if let error = error {
                        
                        assertionFailure(error.localizedDescription)
                        return
                        
                    } else {
                        
                        //Write to database according to ExRequest.swift model
                        let ref = Database.database().reference().child("exRequests").child(firUser.uid).child(exRequestId)
                        ref.updateChildValues(exReqAttrs) { (error, ref) in
                            
                            if let error = error {
                                
                                assertionFailure(error.localizedDescription)
                                return
                            }
                            
                            
                            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                let exRequest = ExRequest(snapshot: snapshot)
                                completion(exRequest)
                            })
                        }
                    }
                }}
        })
    }
    
    //Function to fetch ExRequests from datebase
    static func fetchRequests(for user: FIRUser, completion: @escaping ([ExRequest]) -> Void) {
        let ref = Database.database().reference().child("exRequests").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            var exRequests = snapshot.reversed().compactMap(ExRequest.init)
            
            //Remove old exRequests
            for i in exRequests {
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.calendar = NSCalendar.current
                dateFormatter.dateFormat = "dd-MM-yyyy"
                
                let keys = i.key.components(separatedBy: ",")
                var dateString = keys[0]
                dateString.insert("-", at: dateString.index(dateString.startIndex, offsetBy: 2))
                dateString.insert("-", at: dateString.index(dateString.startIndex, offsetBy: 5))
                
                print("Date from exRequest : \(dateString)")
                
                
                let calendar = Calendar.current
                
                guard let exDate = dateFormatter.date(from: dateString),
                    
                    let dateFinal = calendar.date(byAdding: .hour, value: 23, to: exDate),
                    let index = exRequests.index(where: {$0 === i})
                    else  {print ("Error comparing dates")
                        return}
                print("Date to compare \(dateFinal) and \(Date())")
                if dateFinal < Date() {
                    
                    //Remove Database reference
                    Database.database().reference().child("exRequestsIds").child(i.key).removeValue()
                    Database.database().reference().child("exRequests").child(user.uid).child(i.key).removeValue()
                    
                    //Remove exRequest from array
                    exRequests.remove(at: index)
                    
                }
            }
            completion(exRequests)
        })
        
    }
    
    //Function to find number of matches
    static func numberOfMatchesExRequest(exRequestId exId: String, completion: @escaping(Int) -> Void){
        let ref = Database.database().reference().child("exRequestsIds").child(exId)
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            let snapshotCount = max(Int(snapshot.childrenCount)-1,0)
            completion(snapshotCount)
            
        }) {(error) in
            completion(0)
        }
    }
    
    //Function fo control exchange request average by user
    static func checkPointExReqCreated (for user: FIRUser, completion: @escaping(Bool) -> Void) {
        
        //Reference Database
        let ref = Database.database().reference().child("users").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let exReqCount = value?["exReqCount"] as? Int ?? 0
            let firstDate = value?["firstDate"] as? String ?? "0"
            let lastExReqDate = value?["lastExReqDate"] as? String ?? "0"
            
            print("Exchange Request Count = \(exReqCount)")
            print("First user Date = \(firstDate)")
            print("Last Exchange Request Date = \(lastExReqDate)")
            
            //Days elapsed calculation
            if (firstDate != "0") && (lastExReqDate != "0") {
                //Birth Date Formatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "ddMMyyyy"
                guard let firstDateFormat = dateFormatter.date(from: firstDate),
                    let lastExReqDateFormat = dateFormatter.date(from: lastExReqDate),
                    let diffInDays = Calendar.current.dateComponents([.day], from: firstDateFormat, to: lastExReqDateFormat).day
                    else {return}
                print("Days elased from first day to last Exchange Request day: \(diffInDays)")
                
                //Avoid division by 0
                var exReqAverageDay = Float()
                
                if diffInDays == 0 {
                    exReqAverageDay = 1.0
                } else {
                    exReqAverageDay = Float(exReqCount) / Float(diffInDays)
                }
                
                print ("Average Exchange Requests by day: \(exReqAverageDay)")
                
                if exReqAverageDay <= 5.0 {
                    completion (true)
                } else {
                    completion (false)
                }
            } else {
                completion(true)
            }
            
        }) { (error) in
            print("Error fetching user branch database: \(error.localizedDescription)")
            completion(true)
        }
        
    }
    
}
