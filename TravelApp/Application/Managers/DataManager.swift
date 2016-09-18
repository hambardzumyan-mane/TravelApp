//
//  DataManager.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/15/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import Foundation
import UIKit

protocol DataManagerDelegate {
    
    func placesDidLoad(places: [Place])
}

class DataManager {

    private static let BASE_KEY: String = "list"
    
	static let sharedInstance = DataManager()
    
    var delegate: DataManagerDelegate?
    
	private init() {}
    
    // MARK: - Public Methods
    func loadPlaces() {
        guard let items = CoreDataManager.sharedInstance.getPlaces() else {
            print("TODO")
            HTTPSessionManager.sharedInstance.loadPlaces(self.placesDidLoad)
            return
        }
        if (items.isEmpty) {
            HTTPSessionManager.sharedInstance.loadPlaces(self.placesDidLoad)
            return
        }
        self.delegate?.placesDidLoad(items)
    }
    
    // MARK: - Private Methods
    // MARK: Callbacks
    
    private func placesDidLoad(data: NSData?, error: NSError?) -> Void {
        if nil != error {
            // TODO
            return
        }
        let dict = self.getDictionary(data!)
        let items = dict[DataManager.BASE_KEY] as! Array<AnyObject>

        let places = CoreDataManager.sharedInstance.savePlaces(items)
        self.delegate?.placesDidLoad(places)
    }
    
    // MARK: Utilities
    
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

}
