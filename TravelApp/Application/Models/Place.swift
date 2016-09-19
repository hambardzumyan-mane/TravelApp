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

    private var detailsLoadCompletion: ((NSError?) -> Void)?
    private var imageLoadCompletion: ((place: Place) -> Void)?
    
	convenience init(json: Dictionary<String, AnyObject>, entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
		self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.initalize(json)
	}
    
    func initalize(json: Dictionary<String, AnyObject>) {
        let id = json["id"] as? String ?? "0"
        self.id = Int(id)!
        self.title = json["title"] as? String ?? ""
        self.details = nil
        self.image = nil
        self.loadImage(nil)
    }
    
    func loadDetails(completion: ((NSError?)->Void)?) {
        self.detailsLoadCompletion = completion
        HTTPSessionManager.sharedInstance.loadPlace(id, completion: self.placeDidLoad)
    }
    
    func loadImage(completion: ((place: Place) -> Void)?) {
        self.imageLoadCompletion = completion
        ImageLoader.sharedInstance.load(self.title, completion: self.imageDataDidLoad)
    }
    
    // MARK: - Private Methods
    // MARK: CallBack
    
    private func imageDataDidLoad(data: NSData?) {
        self.image = data
        if nil == data {
            print("Image was not loaded for \"\(self.title)\" place.")
            return
        }
        print("Image loaded for \"\(self.title)\" place.")
        self.imageLoadCompletion?(place: self)
        self.update()
    }
    
    private func placeDidLoad(data: NSData?, error: NSError?) -> Void {
        if nil != error {
            NSLog("Error appeared during \"\(self.title)\" place's details loading. \(error?.description)")
            self.detailsLoadCompletion?(error)
            return
        }
        let items = Utilities.getDictionary(data!) as! Dictionary<String, AnyObject>
        if items.isEmpty || nil != items["error"] {
            let title = "The details are missing."
            let message = "There are no details for \"\(self.title)\" place."
            let err = Utilities.createMyError(title, message: message)
            self.detailsLoadCompletion?(err)
            return
        }
        self.updateDetails(items)
    }
    
    // MARK: Helpers
    
    private func updateDetails(placeDict: Dictionary<String, AnyObject>) {
        let details = NSEntityDescription.insertNewObjectForEntityForName(String(PlaceDetails), inManagedObjectContext: CoreDataManager.sharedInstance.managedObjectContext) as! PlaceDetails
        details.initalize(placeDict)
        self.details = details
        self.detailsLoadCompletion?(nil)
        self.update()
    }
    
    private func update() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            do {
                try self.managedObjectContext?.save()
            } catch (let e) {
                NSLog("Error appeared during \"\(self.title)\" place saving. \(e)")
            }
        }
    }
}
