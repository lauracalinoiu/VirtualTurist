//
//  Pic.swift
//  VirtualTurist
//
//  Created by Laura Calinoiu on 05/12/15.
//  Copyright © 2015 tutorials. All rights reserved.
//

import UIKit
import CoreData

class Pic: NSManagedObject{
    
    struct Keys{
        static let url = "url"
    }
    
    @NSManaged var url: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Pic", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        url = dictionary[Keys.url] as! String
    }
    
    var image: UIImage? {
        get {
            return Static.Caches.imageCache.imageWithIdentifier(url)
        }
        
        set {
            Static.Caches.imageCache.storeImage(image, withIdentifier: url)
        }
    }
    
}