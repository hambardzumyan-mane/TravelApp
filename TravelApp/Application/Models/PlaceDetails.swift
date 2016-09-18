//
//  PlaceDetails.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import Foundation
import CoreData


class PlaceDetails: NSManagedObject {

    convenience init(json: Dictionary<String, AnyObject>, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.initalize(json)
    }
    
    func initalize(json: Dictionary<String, AnyObject>) {
        self.transport = json["transport"] as? String ?? ""
        self.details = json["description"] as? String ?? ""
        self.phone = json["phone"] as? String ?? ""
        self.address = json["address"] as? String ?? ""
        self.email = json["email"] as? String ?? ""
        
        let geo = json["geocoordinates"] as? String ?? ""
        let geoArr = geo.componentsSeparatedByString(",")
        if geoArr.count < 2 {
            return
        }
        
        self.latitude = Double(geoArr[0])
        self.longitude = Double(geoArr[1])
    }
    
}
