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
import Alamofire

class EventViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var eventsCollectionView: UICollectionView!
    
    let refreshControl = UIRefreshControl()
    var eventsArray = [Event]()
    var selectedEventNo : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        
        // Navigation bar & controller settings
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Chat") , style: .Plain, target: self, action: #selector(rightBarButtonItemTouchUpInside))
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
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
        
        // Collection view cell nib register
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle:nil)
        eventsCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "eventCell")
        
        // If there are not enough events to scroll, you can still pull to refresh
        eventsCollectionView.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        cell.location.adjustsFontSizeToFitWidth = true
        cell.time.text = eventsArray[indexPath.row].time
        cell.branchName.text = (eventsArray[indexPath.row].branch).uppercaseString
        
        Alamofire.request(.GET, (self.eventsArray[indexPath.row].creatorImageURL)).responseData{ response in
            if let image = response.result.value {
                cell.creatorImage.layer.masksToBounds = true
                cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                cell.creatorImage.image = UIImage(data: image)
            }
        }
        
        // Flip animation
        UIView.transitionWithView(cell, duration: 0.25, options: .TransitionFlipFromTop, animations: nil, completion: nil)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let eventDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
        eventDetailVC.event = eventsArray[indexPath.row]
        self.presentViewController(eventDetailVC, animated: true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenSize.width, 200)
    }
    
    //
    // Self created methods
    func retrieveData() {
        self.eventsArray =  [Event]()
        
        REF_EVENTS.observeSingleEventOfType(.Value , withBlock: { (snapshot) in
            if snapshot.exists() {
                let postDict = Array((snapshot.value as! [String : AnyObject]).values)
                
                for element in postDict {
                    let id = element.valueForKey("id") as! String
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
                    let year = element.valueForKey("year") as! String
                    
                    let eventElement = Event(creatorID: creatorID, creatorImageURL: creatorImageURL, creatorName: creatorName, name: name, branch: branch, level: level, location: location, maxJoinNumber: maxJoinNumber, description: description, time: time, month: month, day: day, year: year, id: id)
                    
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
            self.performSegueWithIdentifier("eventAddFormSegue", sender: self)
        }
    }
    
    func leftBarButtonItemTouchUpInside() {
        
    }
    
    func rightBarButtonItemTouchUpInside() {
        self.performSegueWithIdentifier("toChannelsSegue", sender: self)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let visibleCells = eventsCollectionView.visibleCells() as? [EventCollectionViewCell] {
            for parallaxCell in visibleCells {
                let yOffset = ((eventsCollectionView.contentOffset.y - parallaxCell.frame.origin.y) / 230) * 25
                parallaxCell.offset(CGPointMake(0.0, yOffset))
            }
        }
    }
}
