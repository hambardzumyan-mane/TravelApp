//
//  MasterViewController.swift
//  TrevelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, UISearchResultsUpdating, DataManagerDelegate {

    private static let DETAIL_SEGUE_ID = "showDetailSegue"
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: [Place] = []
    private var searchedPlaces: [Place] = []
    
    private var loadingView: LoadingView? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		self.splitViewController?.preferredDisplayMode = .AllVisible
        
        self.loadingView = LoadingView()
        self.loadingView?.show(self.splitViewController!.view)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        DataManager.sharedInstance.delegate = self
        DataManager.sharedInstance.loadPlaces()
	}

	override func viewWillAppear(animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
		super.viewWillAppear(animated)
	}
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator);
        coordinator.animateAlongsideTransition(nil, completion: { _ in
            self.loadingView?.update(self.splitViewController!.view.frame)
        })
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MasterViewController.DETAIL_SEGUE_ID {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                let place = (self.searchController.active && !self.searchController.searchBar.text!.isEmpty )
                    ? self.searchedPlaces[indexPath.row]
                    : self.places[indexPath.row]
                controller.title = place.title
                controller.place = place
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let place: Place = self.getPlace(indexPath.row)
            return identifier == MasterViewController.DETAIL_SEGUE_ID && nil != place.details
        }
        return false
    }
    
	// MARK: - Table View

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.searchController.active && !self.searchController.searchBar.text!.isEmpty)
            ? self.searchedPlaces.count
            : self.places.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let place: Place = self.getPlace(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("\(String(PlaceTableViewCell))Id", forIndexPath: indexPath) as! PlaceTableViewCell
        cell.titleLabel.text = place.title
        if let data = place.image {
            cell.backgroundImageView.image = UIImage(data: data)
        } else {
            cell.backgroundImageView.image = UIImage(named: "DefaultPlaceImage")
            place.loadImage(self.placeImageDidLoad)
        }
        return cell
	}
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = self.getPlace(indexPath.row)
        if nil == place.details {
            self.loadingView?.show(self.splitViewController!.view)
            place.loadDetails(self.placeDidUpdate)
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140 // TODO: make generic
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchedText = searchController.searchBar.text!.lowercaseString
        self.searchedPlaces = self.places.filter { place in
           return place.title.lowercaseString.containsString(searchedText)
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    // MARK: - DataManagerDelegate
    
    func placesDidLoad(places: [Place], error: NSError?) {
        if let err = error {
            let alert = Utilities.getInfomationDialog(err)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadingView?.hide()
                self.presentViewController(alert, animated: true, completion: nil)
            })
            return
        }
        self.places = places
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loadingView?.hide()
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Private Methods
    // MARK: CallBack
    
    private func placeDidUpdate(error: NSError?) -> Void {
        if let err = error {
            let alert = Utilities.getInfomationDialog(err)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadingView?.hide()
                self.presentViewController(alert, animated: true, completion: nil)
            })
            return
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loadingView?.hide()
            self.performSegueWithIdentifier(MasterViewController.DETAIL_SEGUE_ID, sender: self)
        })
    }
    
    private func placeImageDidLoad(place: Place) {
        let array = (self.searchController.active && !self.searchController.searchBar.text!.isEmpty)
            ? self.searchedPlaces
            : self.places
        if let index = array.indexOf(place)
            //, let imageData = place.image
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                let indexPaths = self.tableView.indexPathsForVisibleRows
                if nil != indexPaths?.indexOf(indexPath) {
                    self.tableView.reloadData()
                    // This solution dont work for all OS's and devices
                    //let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PlaceTableViewCell
                    //cell.imageView?.image = UIImage(data: imageData)
                }
            })
        }
    }
    
    // MARK: Helper
    
    private func getPlace(row: Int) -> Place {
        return (self.searchController.active && !self.searchController.searchBar.text!.isEmpty)
            ? self.searchedPlaces[row]
            : self.places[row]
    }
}
