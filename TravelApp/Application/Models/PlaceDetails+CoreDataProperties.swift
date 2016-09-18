//
//  PlaceDetails+CoreDataProperties.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PlaceDetails {

    @NSManaged var transport: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var details: String?
    @NSManaged var phone: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var address: String?
    @NSManaged var email: String?
    @NSManaged var place: Place?
}
