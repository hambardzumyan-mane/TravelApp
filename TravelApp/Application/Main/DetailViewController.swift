//
//  DetailViewController.swift
//  TrevelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit
import MapKit
import CoreTelephony

class DetailViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var transportLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!

    var place: Place?

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: uncomment after complete test on iPads
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        guard let placeDetails = self.place?.details else {
            self.scrollView.hidden = true
            self.navigationController?.popToRootViewControllerAnimated(true)
            return
        }
        
        self.emailLabel.text = self.getLabelValue(placeDetails.email, fieldName: "Email")
        self.phoneLabel.text = self.getLabelValue(placeDetails.phone, fieldName: "Telephone")
        self.addressLabel.text = self.getLabelValue(placeDetails.address, fieldName: "Address")
        self.transportLabel.text = self.getLabelValue(placeDetails.transport, fieldName: "Transport")
        self.detailsLabel.text = self.getLabelValue(placeDetails.details, fieldName: "Details")
        
        // Add email Gesture Recognizer
        // TODO: add email validator
        if self.emailLabel.text == placeDetails.email {
            self.addGestureRecognizer(self.emailLabel)
        }

        // Add phone number Gesture Recognizer
        if let phoneNumber = placeDetails.phone {
            self.initPhoneLabel(phoneNumber)
        }
        
        // Set image
        if let imageData = self.place?.image {
            self.imageView.image = UIImage(data: imageData)
        }
        
        // Setup MapView
        if let longitude = placeDetails.longitude as? Double,
            let latitude = placeDetails.latitude as? Double
        {
            self.initMap(latitude, longitude: longitude)
        }
        
    }
    
    private func initMap(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = location.coordinate
        anotation.title = self.title
        self.mapView.addAnnotation(anotation)
    }
    
    private func initPhoneLabel(phoneNumber: String) {
        let number = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
        let networkInfo = CTTelephonyNetworkInfo()
        let carier = networkInfo.subscriberCellularProvider
        if nil == carier?.isoCountryCode || number.characters.count < 3 {
            return
        }
        self.addGestureRecognizer(self.phoneLabel)
    }
    
    private func addGestureRecognizer(label: UILabel) {
        let gesture = UITapGestureRecognizer(target: self,
            action: #selector(DetailViewController.labelDidTap))
        gesture.numberOfTapsRequired = 1
        label.userInteractionEnabled = true
        label.addGestureRecognizer(gesture)
    }
    
    private func getLabelValue(text: String?, fieldName: String) -> String {
        if let txt = text {
            if !txt.isEmpty && "null" != txt
                && "Not specified" != txt  && "Undefined" != txt {
                return txt
            }
        }
        return "\(fieldName) is not specified"
     }
    
    // MARK: Actions
    
    @objc
    private func labelDidTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.view as! UILabel {
        case self.emailLabel:
            if let url = NSURL(string: "mailto:\(self.emailLabel.text!)") {
                UIApplication.sharedApplication().openURL(url)
            }
            break
        case self.phoneLabel:
            let numbers = self.phoneLabel.text!.characters.split{$0 == ";"}.map(String.init)
            for item in numbers {
                let number = item.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                if number.characters.count <= 3 {
                    continue
                }
                let url = NSURL(string: "tel://+\(number)")!
                UIApplication.sharedApplication().openURL(url)
                break
            }
        default:
            return
        }
    }
}
