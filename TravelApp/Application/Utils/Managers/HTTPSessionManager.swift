//
//  HTTPSessionManager.swift
//  LandesmuseumZurich
//
//  Created by Mane Hambardzumyan on 9/15/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit

class HTTPSessionManager: NSObject {

	private let BASE_URL: String = "http://t21services.herokuapp.com/points"

    static let sharedInstance = HTTPSessionManager()

	private override init() { }

	// MARK:- Pubilc Methods

    func loadPlaces(completion: (data: NSData?, error: NSError?) -> Void) -> Void {
		let url = NSURL(string: self.BASE_URL)
        self.makeAsyncHTTPGetRequest(url!, completion: completion)
	}
    
    func loadPlace(id: NSNumber, completion: (data: NSData?, error: NSError?) -> Void) -> Void {
        let url = NSURL(string: "\(self.BASE_URL)/\(id)")
        self.makeAsyncHTTPGetRequest(url!, completion: completion)
    }
    
    func get(url: NSURL, completion: (data: NSData?, error: NSError?) -> Void) -> Void {
        self.makeAsyncHTTPGetRequest(url, completion: completion)
    }

	// MARK:- Utility Method

    func makeAsyncHTTPGetRequest(url: NSURL, completion: (NSData?, NSError?) -> Void) {
		let request = NSMutableURLRequest(URL: url)

		let sessionConfig: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		sessionConfig.timeoutIntervalForRequest = 30.0
		sessionConfig.timeoutIntervalForResource = 60.0
		let session = NSURLSession(configuration: sessionConfig)

		let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
			session.finishTasksAndInvalidate()
			completion(data, error)
		})
		task.resume()
	}
}
