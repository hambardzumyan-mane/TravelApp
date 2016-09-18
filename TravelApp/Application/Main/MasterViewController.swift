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

    private static let detailSegueIdentifier = "showDetailSegue"
	private var places: [Place] = []
    
	private var detailViewController: DetailViewController? = nil
    private var loadingView: LoadingView? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MasterViewController.detailSegueIdentifier {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                let place = self.places[indexPath.row]
                controller.place = place.details
                controller.title = place.title
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            return identifier == MasterViewController.detailSegueIdentifier && nil != self.places[indexPath.row].details
        }
        return false
    }
    
	// MARK: - Table View

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.places.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		//cell.textLabel?.text = self.places[indexPath.row].title
		//return cell
        
        let cell = tableView.dequeueReusableCellWithIdentifier("\(String(PlaceTableViewCell))Id", forIndexPath: indexPath) as! PlaceTableViewCell
        cell.titleLabel.text = self.places[indexPath.row].title
        cell.backgroundImageView.image = UIImage(named: "image.jpg")
        return cell
	}
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = self.places[indexPath.row]
        if nil == place.details {
            self.loadingView?.show(self.splitViewController!.view)
            place.loadDetails(self.placeDidUpdate)
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140 // TODO make generic
    }
    
    // MARK: - DataManagerDelegate
    
    func placesDidLoad(places: [Place]) {
        self.places = places
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loadingView?.hide()
            self.tableView.reloadData()
        })
    }
    
    // MARK: - CallBack
    private func placeDidUpdate() -> Void {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loadingView?.hide()
            self.performSegueWithIdentifier(MasterViewController.detailSegueIdentifier, sender: self)
            
        })
    }
}
