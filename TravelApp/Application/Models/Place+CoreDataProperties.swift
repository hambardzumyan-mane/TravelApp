//
//  Place+CoreDataProperties.swift
//  TravelApp
//
//  Created by Areg Gareginyan on 9/18/16.
//  Copyright © 2016 Mane. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  /Users/areg.gareginyan/Workspace/TravelApp/TravelApp/Application/Managers/DataManager.swiftto delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Place {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var image: NSData?
    @NSManaged var details: PlaceDetails?

}
