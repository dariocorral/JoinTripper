//
//  Languages+CoreDataProperties.swift
//  JoinTripper
//
//  Created by Dario Corral on 13/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//
//

import Foundation
import CoreData


extension Languages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Languages> {
        return NSFetchRequest<Languages>(entityName: "Languages")
    }

    @NSManaged public var code: String?
    @NSManaged public var name: String?

}
