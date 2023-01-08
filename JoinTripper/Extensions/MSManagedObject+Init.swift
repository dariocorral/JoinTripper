//
//  MSManagedObject+Init.swift
//  JoinTripper
//
//  Created by Dario Corral on 13/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObject {
    
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
}
