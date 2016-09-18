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

    private var completion: (() -> Void)?
    
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
        ImageLoader.sharedInstance.load(self.title, completion: imageDataDidLoad)
        
    }
    
    private func imageDataDidLoad(data: NSData?) {
        print("gugush")
        print(self.title)
    }
    
    func loadDetails(completion: (()->Void)?) {
        self.completion = completion
        HTTPSessionManager.sharedInstance.loadPlace(id, completion: self.placeDidLoad)
    }
    
    // MARK: - CallBack
    
    private func placeDidLoad(data: NSData?, error: NSError?) -> Void {
        if nil != error {
            // TODO
            return
        }
        let items = self.getDictionary(data!) as! Dictionary<String, AnyObject>
        self.savePlaceDetails(items)
        self.completion?()
    }
    
    // MARK: MV Utilities
    
    private func getDictionary(data: NSData) -> NSDictionary {
        var dictionary: NSDictionary?
        do {
            dictionary = (try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary ?? [String: AnyObject]()
        } catch let error {
            NSLog("Error appeared during json serialization: \(error)")
            dictionary = [:]
        }
        return dictionary!
    }
    
    private func savePlaceDetails(placeDict: Dictionary<String, AnyObject>) {
        let details = NSEntityDescription.insertNewObjectForEntityForName(String(PlaceDetails), inManagedObjectContext: CoreDataManager.sharedInstance.managedObjectContext) as! PlaceDetails
        self.details = details
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            do {
                try self.managedObjectContext?.save()
            } catch (let e) {
                NSLog("Error appeared during \"\(self.title)\" place saving. \(e)")
            }
        }
    }
}
