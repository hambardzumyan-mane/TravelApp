//
//  Place.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import Foundation
import CoreData

class Place: NSManagedObject {

	convenience init(json: Dictionary<String, AnyObject>, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
		self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.initalize(json)
	}
    
    func initalize(json: Dictionary<String, AnyObject>) {
        self.id = json["id"] as? Int ?? 0
        self.title = json["title"] as? String ?? ""
        self.details = nil
    }
}
