//
//  CoreDataManager.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
	private static let storeName: String = "TravelCoreData.sqlite"
	private static let modmName = "TravelApp"
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator

    static let sharedInstance =  CoreDataManager()
    
    let managedObjectContext: NSManagedObjectContext = {
            let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
            moc.undoManager = nil
            moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return moc
    }()
    
    let managedObjectModel: NSManagedObjectModel = {
		let modelURL = NSBundle.mainBundle().URLForResource(CoreDataManager.modmName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count - 1]
	}()
    
    // MARK: - Privates
    
    private init() {
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        let docUrl: NSURL = urls[urls.count - 1] as NSURL
        let url = docUrl.URLByAppendingPathComponent(CoreDataManager.storeName)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
        }
        
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }

	private func saveContext() {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
    
    // MARK: - Public Methods
    // MARK: Core Data Save func
    
    func savePlaces(placesDict: Array<AnyObject>) -> [Place] {
        var places: [Place] = []
        for placeData in placesDict {
            let place = NSEntityDescription.insertNewObjectForEntityForName(String(Place), inManagedObjectContext: managedObjectContext) as! Place
            if let item = placeData as? Dictionary<String, AnyObject> {
                place.initalize(item)
                if (0 == place.id || place.title.isEmpty) {
                    continue
                }
                places.append(place)
            }
        }
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.saveContext()
        }
        return places
    }
    
    func getPlaces() -> [Place]? {
        let placeFetch = NSFetchRequest(entityName: String(Place))
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        do {
            return try managedObjectContext.executeFetchRequest(placeFetch) as? [Place]
        } catch {
            // TODO: change
            fatalError("Failed to fetch places: \(error)")
        }
    }
}
