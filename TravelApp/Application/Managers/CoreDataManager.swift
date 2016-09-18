//
//  CoreDataManager.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import Foundation
import CoreData

//	internal static let sharedInstance = DataManager()

class CoreDataManager { //: NSObject {

	private static let storeName: String = "TrevelCoreData.sqlite"
	private static let modmName = "TrevelApp"

	//let persistentStoreCoordinator: NSPersistentStoreCoordinator
    

	static let sharedInstance =  CoreDataManager()
    /*{
		get {
			struct Static {
				static var instance: CoreDataManager? = nil
				static var token: dispatch_once_t = 0
			}
			dispatch_once(&Static.token) {
				Static.instance = CoreDataManager()
			}
			return Static.instance!
		}
	}*/
    
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
    
    let managedObjectContext: NSManagedObjectContext = {
            let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
            moc.undoManager = nil
            moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            return moc
    }()
    

    var persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    let managedObjectModel: NSManagedObjectModel = {
		let modelURL = NSBundle.mainBundle().URLForResource(CoreDataManager.modmName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()


	/*
	 lazy var persistentStoreCoordinator1: NSPersistentStoreCoordinator = {
	 let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	 let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(CoreDataManager.storeName)
	 var failureReason = "There was an error creating or loading the application's saved data."
	 do {
	 let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(CoreDataManager.storeName)
	 } catch {
	 var dict = [String: AnyObject]()
	 dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
	 dict[NSLocalizedFailureReasonErrorKey] = failureReason

	 dict[NSUnderlyingErrorKey] = error as NSError
	 let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
	 // Replace this with code to handle the error appropriately.
	 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	 NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
	 abort()
	 }

	 return coordinator
	 }()
	 */

	lazy var applicationDocumentsDirectory: NSURL = {
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count - 1]
	}()

	// MARK: - Core Data Saving support

	func saveContext() {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
    
    func savePlaces(placesDict: Array<AnyObject>) -> [Place] {
        var places: [Place] = []
        for placeData in placesDict {
            let place = NSEntityDescription.insertNewObjectForEntityForName(String(Place), inManagedObjectContext: managedObjectContext) as! Place
            if let item = placeData as? Dictionary<String, AnyObject> {
                place.initalize(item)
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
