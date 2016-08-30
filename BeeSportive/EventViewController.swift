//
//  EventViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 16.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Async
import Firebase
import FirebaseDatabase
import REFrostedViewController

class EventViewController: UIViewController {
    
    @IBOutlet var eventsCollectionView: UICollectionView!
    
    let screenSize = UIScreen.mainScreen().bounds.size
    let databaseRef = FIRDatabase.database().reference()
    let refreshControl = UIRefreshControl()
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var eventsArray = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar & controller settings
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.translucent = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Profile3") , style: .Plain, target: self, action: #selector(leftBarButtonItemTouchUpInside))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Chat") , style: .Plain, target: self, action: #selector(rightBarButtonItemTouchUpInside))
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo.png"))
        
        // Check if user is logged in or not
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                // User already logged 
                print("User already logged in")
            } else {
                // No user is signed in.
                Async.main{
                    self.performSegueWithIdentifier("EventsToLoginSegue", sender: self)
                }
            }
        }
        
        // Get daha from database and update collection view
        retrieveData()
        
        // Pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(retrieveData), forControlEvents: UIControlEvents.ValueChanged)
        eventsCollectionView.addSubview(refreshControl)
        
        // Sidebar pan gesture
        self.frostedViewController.panGestureEnabled = true

        // Collection view cell nib register
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle:nil)
        eventsCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "eventCell")
        
        // If there are not enough events to scroll, you can still pull to refresh
        eventsCollectionView.alwaysBounceVertical = true
    }

    //
    // CollectionView Delegate Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eventsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = eventsCollectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
        
        // Filling cell
        cell.backgroundImage.image = UIImage(named: eventsArray[indexPath.row].branch)
        cell.creatorName.text = eventsArray[indexPath.row].creatorName
        cell.dateDay.text = eventsArray[indexPath.row].day
        cell.dateMonth.text =  months[Int(eventsArray[indexPath.row].month)! - 1]
        cell.location.text = eventsArray[indexPath.row].location
        cell.time.text = eventsArray[indexPath.row].time
        
        // Flip animation
        UIView.transitionWithView(cell, duration: 0.5, options: .TransitionFlipFromTop, animations: nil, completion: nil)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenSize.width, 130)
    }
    
    //
    // Self created methods
    func retrieveData() {
        self.eventsArray =  [Event]()
        
        databaseRef.child("events").observeSingleEventOfType(.Value , withBlock: { (snapshot) in
            if snapshot.exists() {
                let postDict = Array((snapshot.value as! [String : AnyObject]).values)
                
                for element in postDict {
                    let creatorID = element.valueForKey("creatorID") as! String
                    let creatorImageURL = element.valueForKey("creatorImageURL") as! String
                    let creatorName = element.valueForKey("creatorName") as! String
                    let name = element.valueForKey("name") as! String
                    let branch = element.valueForKey("branch") as! String
                    let level = element.valueForKey("level") as! String
                    let location = element.valueForKey("location") as! String
                    let maxJoinNumber = element.valueForKey("maxJoinNumber") as! String
                    let description = element.valueForKey("description") as! String
                    let time = element.valueForKey("time") as! String
                    let month = element.valueForKey("month") as! String
                    let day = element.valueForKey("day") as! String
                    
                    let eventElement = Event(creatorID: creatorID, creatorImageURL: creatorImageURL, creatorName: creatorName, name: name, branch: branch, level: level, location: location, maxJoinNumber: maxJoinNumber, description: description, time: time, month: month, day: day)
                    
                    self.eventsArray.insert(eventElement, atIndex: 0)
                }
                
                Async.main {
                    self.refreshControl.endRefreshing()
                    self.eventsCollectionView.reloadData()
                }
            } else {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    //
    // Button actions
    @IBAction func loginButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("EventsToLoginSegue", sender: self)
    }
    
    @IBAction func didTouchUpInside(sender: AnyObject) {
        Async.main{
            self.performSegueWithIdentifier("createEventSegue", sender: self)
        }
    }
    
    func leftBarButtonItemTouchUpInside() {
        self.frostedViewController.presentMenuViewController()
    }
    
    func rightBarButtonItemTouchUpInside() {
        
    }
    
    func panGestureRecognized(sender : UIScreenEdgePanGestureRecognizer){
        self.frostedViewController.panGestureRecognized(sender)
    }
}