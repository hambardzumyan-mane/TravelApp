//
//  Utilities.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/19/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static let APP_NAME = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String ?? "TravelApp"

    static func getDictionary(data: NSData) -> NSDictionary {
        var dictionary: NSDictionary?
        do {
            dictionary = (try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary ?? [String: AnyObject]()
        } catch let error {
            NSLog("Error appeared during json serialization: \(error)")
            dictionary = ["error" : "\(error)"]
        }
        return dictionary!
    }
    
    static func createMyError(title: String, message: String) -> NSError {
        let userInfo: [NSObject : AnyObject] = [
            "title" :  title,
            "message" : message
        ]
        return NSError(domain: APP_NAME, code: 0, userInfo: userInfo)
    }
    
    // TODO: Rename
    
    static func getInfomationDialog(error: NSError) -> UIAlertController {
        let title: String
        let message: String
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
            title = "No Internet Connection"
            message = "The data is not cashed and as there is no Internet connection you can not view it. Please try again after reconnecting to Internet."
        } else if error.domain == APP_NAME {
            let userInfo = error.userInfo as! [String: String]
            title = userInfo["title"] ?? "Data loading error"
            message = userInfo["message"] ?? "Could not load place details data."
        } else {
            title = "Unkown error"
            message =  "The was an error while loading data for selected place. \(error.description)"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    
    // MARK: - Image
    
    static func cropImage(rect: CGRect, image: UIImage) -> UIImage? {
        if rect == CGRectZero {
            return nil
        }
        
        let size = image.size
        let rectSize = rect.size
        var diff = size.width < size.height ? (rectSize.width / size.width) : (rectSize.height / size.height)
        
        var newHeight = size.width * diff
        var newWidth = size.height * diff
        
        if (newWidth < rectSize.width || newHeight < rectSize.height) {
            diff = size.width > size.height ? (rectSize.width / size.width) : (rectSize.height / size.height)
            newHeight = size.width * diff
            newWidth = size.height * diff
        }
        
        let cropRect = CGRectMake(0, 0, newWidth, newHeight)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage!, cropRect)!
        let imageLink = UIImage(CGImage: imageRef)
        let croppedImage = UIImage(data: UIImageJPEGRepresentation(imageLink, 1.0)!)!
        return croppedImage
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
