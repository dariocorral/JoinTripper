//
//  Airports+CoreDataProperties.swift
//  JoinTripper
//
//  Created by Dario Corral on 14/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//
//

import Foundation
import CoreData


extension Airports {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Airports> {
        return NSFetchRequest<Airports>(entityName: "Airports")
    }

    @NSManaged public var code: String?
    @NSManaged public var distance: Double
    @NSManaged public var name: String?

}
