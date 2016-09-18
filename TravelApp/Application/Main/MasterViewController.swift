//
//  MasterViewController.swift
//  TrevelApp
//
//  Created by Mane Hambardzumyan on 9/13/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, DataManagerDelegate {

	private var places: [Place] = []
    
	private var detailViewController: DetailViewController? = nil
    private var loadingView: LoadingView? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

		if let split = self.splitViewController {
			let controllers = split.viewControllers
			self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
		}
        
        self.loadingView = LoadingView()
        self.loadingView?.show(self.splitViewController!.view)
        
        DataManager.sharedInstance.delegate = self
        DataManager.sharedInstance.loadPlaces()
	}

	override func viewWillAppear(animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
		super.viewWillAppear(animated)
        /*
        let url = NSURL(string: "https://www.googleapis.com/customsearch/v1?q=mane&key=AIzaSyBV_JhGLChkeGPXQMN_jfs_B3-H07GymtE&cx=001314759666045002582:onlaqxqgm-i")!
        
        guard let data = HTTPSessionManager.sharedInstance.makeSyncHTTPGetRequest(url) else {
            return
        }
        let mm = data as? String
        let a = self.getDictionary(data)
        let keys = a?.allKeys as? [String]
        let val = a?[keys![0]] as! Dictionary<String, AnyObject>
        let val1 = val["errors"] as? AnyObject?
        let val3 = val["code"] as! Int
        let val2 = val["message"] as! String
         */
	}
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator);
        coordinator.animateAlongsideTransition(nil, completion: {
            _ in
            self.loadingView?.update(self.splitViewController!.view.frame)
        })
    }
    
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - Segues
//	/*
//	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//	 if segue.identifier == "showDetail" {
//	 if let indexPath = self.tableView.indexPathForSelectedRow {
//	 let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
//	 let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//	 controller.detailItem = object
//	 controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//	 controller.navigationItem.leftItemsSupplementBackButton = true
//	 }
//	 }
//	 }
//	 */
    
	// MARK: - Table View

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.places.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		cell.textLabel?.text = self.places[indexPath.row].title
		return cell
	}
    
    // MARK: - DataManagerDelegate
    
    func placesDidLoad(places: [Place]) {
        self.places = places
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loadingView?.hide()
            self.tableView.reloadData()
        })
    }
}
