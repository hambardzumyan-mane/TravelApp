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
    
    func placesDidLoad(places: [Place], error: NSError?)
}

class DataManager {

    private static let BASE_KEY: String = "list"
    
	static let sharedInstance = DataManager()
    
    var delegate: DataManagerDelegate?
    
	private init() {}
    
    // MARK: - Public Method
    
    func loadPlaces() {
        guard let items = CoreDataManager.sharedInstance.getPlaces() else {
            HTTPSessionManager.sharedInstance.loadPlaces(self.placesDidLoad)
            return
        }
        if (items.isEmpty) {
            HTTPSessionManager.sharedInstance.loadPlaces(self.placesDidLoad)
            return
        }
        self.delegate?.placesDidLoad(items, error: nil)
    }
    
    // MARK: - Private Method
    // MARK: Callbacks
    
    private func placesDidLoad(data: NSData?, error: NSError?) -> Void {
        if let err = error {
            NSLog("Error appeared during places list loading. \(err.description)")
            self.delegate?.placesDidLoad([], error: err)
            return
        }
        let dict = Utilities.getDictionary(data!) as! Dictionary<String, AnyObject>
        if dict.isEmpty || nil != dict["error"] {
            let title = "The places are missing."
            let message = "The response is not correct. Could you please try it again later."
            let err = Utilities.createMyError(title, message: message)
            self.delegate?.placesDidLoad([], error: err)
            return
        }
        
        let items = dict[DataManager.BASE_KEY] as! Array<AnyObject>

        let places = CoreDataManager.sharedInstance.savePlaces(items)
        self.delegate?.placesDidLoad(places, error: nil)
    }

}
