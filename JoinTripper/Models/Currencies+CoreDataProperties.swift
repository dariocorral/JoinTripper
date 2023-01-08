//
//  Currencies+CoreDataProperties.swift
//  JoinTripper
//
//  Created by Dario Corral on 13/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//
//

import Foundation
import CoreData


extension Currencies {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currencies> {
        return NSFetchRequest<Currencies>(entityName: "Currencies")
    }

    @NSManaged public var name: String?
    @NSManaged public var symbol: String?

}
