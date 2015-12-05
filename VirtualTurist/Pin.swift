//
//  Pin.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 05/12/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject{
    
    struct Keys{
        static let lat = "lat"
        static let lon = "lon"
    }
    
    @NSManaged var lat: Double
    @NSManaged var lon: Double
    @NSManaged var pics: [Pic]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        lat = dictionary[Keys.lat] as! Double
        lon = dictionary[Keys.lon] as! Double
    }
    
}
