//
//  ImageLoadTask.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/18/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit

class ImageLoadTask: NSObject {
    
    private static let API_KEY: String = "AIzaSyCaXEfbAdEa0QCH2szgUGnbHzX1oDucmMw"
    //"AIzaSyC1a7OqScY7dIs895Q5jL_GRCX4p1q2G9k" 
    //"AIzaSyBV_JhGLChkeGPXQMN_jfs_B3-H07GymtE"
    private static let SEARCH_ENGINE_ID: String = "001273574390373110845:gdm5dmhp6wa"
    //"003083014003710902134:86tsrdx5i1i" 
    //"001314759666045002582:onlaqxqgm-i"
    private static let SEARCH_SCHEME: String = "https"
    private static let SEARCH_HOST: String = "www.googleapis.com"
    private static let SEARCH_PATH: String = "/customsearch/v1"
    
    private static let BASE_KEY: String = "items"

    private var name : String
    private var imageDataHandler : (data: NSData?) -> Void
    private var taskCompletionHandler : () -> Void
    
    // MARK: - Public Methods
    
    init(name: String, imageDataHandler: (data: NSData?) -> Void, taskCompletionHandler: () -> Void) {
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
        HTTPSessionManager.sharedInstance.get(urlComponents.URL!, completion: imageSrcDidLoad)
    }
    
    // MARK:- Private Methods
    // MARK: Callbacks
    
    private func imageSrcDidLoad(data: NSData?, error: NSError?) -> Void {
        if (nil != error) {
            //NSLog("Error appeared during image load: \(error)")
            self.taskCompletionHandler()
            self.imageDataHandler(data: nil)
            return
        }
        
        let dictionary = Utilities.getDictionary(data!) as! Dictionary<String, AnyObject>
        if (dictionary.isEmpty || nil != dictionary["error"]) {
            self.taskCompletionHandler()
            self.imageDataHandler(data: nil)
            if let err = dictionary["error"] {
                print(err["message"])
                NSLog("The image serching limit is reached for today. Error: \(err)")
            }
            return
        }
        
        let items = dictionary[ImageLoadTask.BASE_KEY] as? Array<Dictionary<String, AnyObject>>
        if nil == items || items!.isEmpty {
            self.imageDataHandler(data: nil)
            self.taskCompletionHandler()
            return
        }
        let pagemap = items![0]["pagemap"] as! Dictionary<String, Array<AnyObject>>
        let cseImage = pagemap["cse_image"]![0] as! Dictionary<String, String>
        let src = cseImage["src"]!
        let url = NSURL(string: src)
        HTTPSessionManager.sharedInstance.get(url!, completion: imageDataDidLoad)
    }
    
    private func imageDataDidLoad(data: NSData?, error: NSError?) -> Void {
        if (nil != error || nil == data) {
            print(error)
            self.imageDataHandler(data: nil)
            self.taskCompletionHandler()
            return
        }
        self.imageDataHandler(data: data!)
        self.taskCompletionHandler()
    }
}
