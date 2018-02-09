//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Vale Calderon  on 4/10/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var photoID: NSNumber?


}
