//
//  UserService.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseAuth.FIRUser
import FirebaseDatabase
import FirebaseMessaging
import CoreData



//MARK: - Protocol Printable
protocol Printable {
    var description: String { get }
}

//MARK: - Enum Gender to add database info
enum Gender: Int ,CaseIterable {
    case male
    case female
    
//    static var count: Int { return Gender.female.hashValue + 1}
//
    var description: String {
        switch self {
        
        case .male: return "Male"
        case .female   : return "Female"

        }
    }
}

//MARK: - User related networking
//This allow connect with a different database system

struct UserService {
    
    //Func to search currency value inside core data for user's country
    static func searchCurrencyValue(_ countryText: String) -> String? {
        
        //Search value currency from core data
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let predicate = NSPredicate(format: "name == %@", countryText)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Countries")
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try managedContext.fetch(fetchRequest)
            
            let currency = results[0] as! NSManagedObject
            guard let currencyText  = currency.value(forKey: "symbol")  else { return nil}
            print("Currency is \(currencyText)")
            
            return currencyText as? String
            
        } catch let error as NSError {
            
            print("Could not fetch Filtered Currencies Data: \(error), \(error.userInfo)")
            
            return nil
        }
        
    }
    
    static func username (_ firUser: FIRUser, completion: @escaping(String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser  else{ return}
        
        let ref = Database.database().reference().child("users").child(currentUser.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            completion(user?.username)
        })
    }
    
    
    static func create(_ firUser: FIRUser, username: String, gender: String, dateOfBirth: String, country: String, languages:String, completion: @escaping (User?) -> Void) {
        
        
        guard let currency = UserService.searchCurrencyValue(country) else { return }
        let token = Messaging.messaging().fcmToken
        
        let dateFommatter = DateFormatter()
        dateFommatter.dateFormat = "ddMMyyyy"
        let firstDate = dateFommatter.string(from: Date())
        
        let userAttrs = ["username": username , "gender": gender , "dateOfBirth": dateOfBirth , "country": country , "currency": currency , "email": firUser.email as Any, "token": token as Any ,"languages": languages , "exReqCount": 0 , "firstDate" : firstDate, "lastExReqDate" : "0" ] as [String : Any]
        
        let usernameRootAttrs = [ username : firUser.uid]
        
        //Check if there is a value with username
        let refNorm = Database.database().reference().child("usernames")
        refNorm.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if snapshot.hasChild(username){
                
                completion(nil)
                
            } else {
                
                //Write to database branch with Username /uid to normalize
                refNorm.updateChildValues(usernameRootAttrs) { (error, refNorm) in
                    if let error = error {
                        
                        print("\(error.localizedDescription)")
                        return
                        
                    } else {
                        
                        //Write to database uid and username. Define defaults user according to User.swift model
                        let ref = Database.database().reference().child("users").child(firUser.uid)
                        ref.setValue(userAttrs) { (error, ref) in
                            
                            if let error = error {
                                
                                print("\(error.localizedDescription)")
                                return
                            }
                            
                            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                let user = User(snapshot: snapshot)
                                completion(user)
                            })
                        }
                    }
                }}
        })
    }
    
    //Function to show user
    static func show (forUID uid: String, completion: @escaping (User?) -> Void) {
        
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion (nil)
            }
            
            completion(user)
        })
    }
    
    //Function to fetch User Profile info from datebase
    static func fetchUserFields(for user: FIRUser, completion: @escaping (UserProfile?) -> Void) {
        let ref = Database.database().reference().child("users").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userProfile = UserProfile.init(snapshot: snapshot ) else { return }
            
            completion(userProfile)
        })
    }
    
    //Function to fetch User Profile Array from datebase
    static func fetchUsersUidsFromExRequest(exRequest exRequestIdInverse: String, completion: @escaping ([String]) -> Void) {
        let ref = Database.database().reference().child("exRequestsIds").child(exRequestIdInverse)
        
        //Fir User To check if the current user is included
        guard let firUser = Auth.auth().currentUser else {return}
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            var uidKeys = [String]()
            
            for item in snapshot {
                //Not include current user
                if item.key != firUser.uid{
                    uidKeys.append(item.key)
                }
            }
            
            completion(uidKeys)
            
        })
        
    }
    
    //Function to Vote positive a user
    static func voteUser(_ firUser: FIRUser, usertToVote: String, positiveVote: Bool, completion: @escaping (String?) -> Void) {
        
        let refPos = Database.database().reference().child("votes").child(usertToVote).child("positive")
        
        let refNeg = Database.database().reference().child("votes").child(usertToVote).child("negative")
        
        refPos.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if snapshot.hasChild(firUser.uid){
                
                completion(nil)
                
            } else {
                
                refNeg.observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    if snapshot.hasChild(firUser.uid){
                        
                        completion(nil)
                        
                    } else {
                        if positiveVote {
                            
                            refPos.updateChildValues([firUser.uid: true])
                            let positiveVoteMsg = "Positive Vote for \(firUser.uid) added"
                            print(positiveVoteMsg)
                            completion(positiveVoteMsg)
                            
                        } else {
                            
                            refNeg.updateChildValues([firUser.uid: true])
                            let negativeVoteMsg = "Negative Vote for \(firUser.uid) added"
                            print(negativeVoteMsg)
                            completion(negativeVoteMsg)
                            
                        }
                    }
                })
            }
        })
    }
    
    //Fetch count positive/negative votes received
    static func votesForUserCount(_ uid: String, positiveVotes: Bool, completion: @escaping (Int) -> Void) {
        
        var ref: DatabaseReference
        
        switch positiveVotes {
        case true:  ref = Database.database().reference().child("votes").child(uid).child("positive")
        case false:
            ref = Database.database().reference().child("votes").child(uid).child("negative")
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(0)
            }
            completion(snapshot.count)
            
        })
    }
    
    //Fetch exRequest from user uid
    static func exRequestFromUserUid(_ uid: String, completion:@escaping([String]?) -> Void) {
        
        let ref = Database.database().reference().child("exRequests").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                
                return completion(nil)
            }
            
            var exRequest = [String]()
            for item in snapshot {
                let itemAny = item.key as Any
                guard let itemString = itemAny as? String else {return}
                exRequest.append(itemString)
            }
            completion(exRequest)
            
        })
        
    }
}

