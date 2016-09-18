//
//  ImageLoadTask.swift
//  TravelApp
//
//  Created by Areg Gareginyan on 9/18/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit

class ImageLoadTask: NSObject {
    
    static private let API_KEY: String = "AIzaSyC1a7OqScY7dIs895Q5jL_GRCX4p1q2G9k"
    static private let SEARCH_ENGINE_ID: String = "003083014003710902134:86tsrdx5i1i"
    static private let SEARCH_SCHEME: String = "https"
    static private let SEARCH_HOST: String = "www.googleapis.com"
    static private let SEARCH_PATH: String = "/customsearch/v1"
    
    var name : String
    var imageDataHandler : (data: NSData?) -> Void
    var taskCompletionHandler : () -> Void
    
    // MARK: Public methods
    
    init(name: String,
         imageDataHandler: (data: NSData?) -> Void,
         taskCompletionHandler: () -> Void) {
        self.name = name
        self.imageDataHandler = imageDataHandler
        self.taskCompletionHandler = taskCompletionHandler
    }
    
    func run() {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = ImageLoadTask.SEARCH_SCHEME
        urlComponents.host = ImageLoadTask.SEARCH_HOST
        urlComponents.path = ImageLoadTask.SEARCH_PATH
        let qQuery = NSURLQueryItem(name: "q", value: name)
        let keyQuery = NSURLQueryItem(name: "key", value: ImageLoadTask.API_KEY)
        let cxQuery = NSURLQueryItem(name: "cx", value: ImageLoadTask.SEARCH_ENGINE_ID)
        let numQuery = NSURLQueryItem(name: "num", value: "1")
        let fieldsQuery = NSURLQueryItem(name: "fields", value: "items/pagemap/cse_image/src")
        urlComponents.queryItems = [qQuery, keyQuery, cxQuery, numQuery, fieldsQuery]
        HTTPSessionManager.sharedInstance.get(urlComponents.URL!, completion: imgSrcDidLoad)
    }
    
    // MARK: Callbacks
    
    private func imgSrcDidLoad(data: NSData?, error: NSError?) -> Void {
        // TODO: - handle error
        if (nil != error) {
            print(error)
            taskCompletionHandler()
            imageDataHandler(data: nil)
            return
        }
        var dictionary: NSDictionary?
        do {
            dictionary = (try NSJSONSerialization.JSONObjectWithData(data!,
                options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary ?? [String: AnyObject]()
        } catch let error {
            NSLog("Error appeared during json serialization: \(error)")
            dictionary = [:]
        }
        if (dictionary?.count == 0) {
            taskCompletionHandler()
            imageDataHandler(data: nil)
            return
        }
        let items = dictionary?.objectForKey("items") as! Array<Dictionary<String, AnyObject>>
        let pagemap = items[0]["pagemap"] as! Dictionary<String, Array<AnyObject>>
        let cseImage = pagemap["cse_image"]![0] as! Dictionary<String, String>
        let src = cseImage["src"]!
        let url = NSURL(string: src)
        HTTPSessionManager.sharedInstance.get(url!, completion: imageDataDidLoad)
    }
    
    private func imageDataDidLoad(data: NSData?, error: NSError?) -> Void {
        // TODO: - handle error
        print("image loaded")
        if (nil != error || nil == data) {
            print(error)
            imageDataHandler(data: nil)
            taskCompletionHandler()
            return
        }
        imageDataHandler(data: data!)
        taskCompletionHandler()
    }

}
