//
//  User.swift
//  JoinTripper
//
//  Created by Dario Corral on 15/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    
    //MARK: - Singleton
    //Use singleton pattern only when there is not another option
    
    // Private static variable to hold current user
    private static var _current: User?
    
    //Computed variable, getter it can not be access outside class
    static var current: User {
        
        //Check _current is not nil, otherwise fatal error
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        //If current user is not nil, return currentUser
        return currentUser
    }
    
    //MARK: - Class Method
    
    //Custom setter method to set current user and persist this current user
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) throws {
        
        if writeToUserDefaults {
            //let data = NSKeyedArchiver.archivedData(withRootObject: user)
            let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        
        _current = user
    }
    
    
    //MARK: - Properties
    
    let uid: String
    let username: String
    
    //MARK: - Init
    
    init(uid: String, username: String) {
        
        self.uid = uid
        self.username = username
        
        //Call to NSObject superclass
        super.init()
    }
    
    //Failable initializer -> returns nil if fails
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any],
            let username = dict["username"] as? String
            else {return nil}
        
        self.uid = snapshot.key
        self.username = username
        
        //Call to NSObject superclass
        super.init()
    }
    
    //In order to conforms NSCoding it is mandatory this init
    required init?(coder aDecoder: NSCoder) {
        
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
            else {return nil}
        
        self.uid = uid
        self.username = username
        
        super.init()
        
    }
    
}

//MARK: - NSCoding Extension

extension User: NSCoding {
    
    func encode (with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
    }
}
