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

class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet var firstView: UIView!
    @IBOutlet var secondView: UIView!
    @IBOutlet var thirdView: UIView!
    @IBOutlet var fourthView: UIView!
    
    @IBOutlet var firstCollectionView: UICollectionView!
    @IBOutlet var secondCollectionView: UICollectionView!
    @IBOutlet var thirdCollectionView: UICollectionView!
    @IBOutlet var fourthCollectionView: UICollectionView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    let refreshControl1 = UIRefreshControl()
    let refreshControl2 = UIRefreshControl()
    let refreshControl3 = UIRefreshControl()
    
    var allEvents = [Event]()
    var favoriteSports = [String]()
    var popularEvents = [Event]()
    var favoriteEvents = [Event]()
    var selectedEventNo : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Navigation bar & controller settings
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Chat") , style: .Plain, target: self, action: #selector(leftBarButtonItemTouchUpInside))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Chat") , style: .Plain, target: self, action: #selector(rightBarButtonItemTouchUpInside))
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        // Get data from database and update collection view
        retrieveAllEvents()
        retrievePopularEvents()
        
        // Pull to refresh
        refreshControl1.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl1.addTarget(self, action: #selector(retrieveAllEvents), forControlEvents: UIControlEvents.ValueChanged)
        firstCollectionView.addSubview(refreshControl1)
        
        refreshControl2.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl2.addTarget(self, action: #selector(retrievePopularEvents), forControlEvents: UIControlEvents.ValueChanged)
        secondCollectionView.addSubview(refreshControl2)
        
        refreshControl3.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl3.addTarget(self, action: #selector(retrieveAllEvents), forControlEvents: UIControlEvents.ValueChanged)
        thirdCollectionView.addSubview(refreshControl3)
        
        // Collection view cell nib register
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle:nil)
        let nibName2 = UINib(nibName: "FavoriteSportCollectionViewCell", bundle:nil)
        
        firstCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "eventCell")
        secondCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "eventCell")
        thirdCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "eventCell")
        fourthCollectionView.registerNib(nibName2, forCellWithReuseIdentifier: "FavoriteSportCell")
        
        // If there are not enough events to scroll, you can still pull to refresh
        firstCollectionView.alwaysBounceVertical = true
        secondCollectionView.alwaysBounceVertical = true
        thirdCollectionView.alwaysBounceVertical = true
    }
    
    // MARK: - CollectionView Delegate Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == firstCollectionView {
            return allEvents.count
        } else if collectionView == secondCollectionView {
            return popularEvents.count
        } else if collectionView == thirdCollectionView {
            return favoriteEvents.count
        } else if collectionView == fourthCollectionView {
            return branchs.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == firstCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
            
            // Filling cell
            cell.date.text = allEvents[indexPath.row].day + " " + months[Int(allEvents[indexPath.row].month)! - 1] + ", " + allEvents[indexPath.row].time
            cell.backgroundImage.image = UIImage(named: allEvents[indexPath.row].branch)
            cell.creatorName.text = allEvents[indexPath.row].creatorName
            cell.location.text = allEvents[indexPath.row].location
            cell.location.adjustsFontSizeToFitWidth = true
            cell.branchName.text = (allEvents[indexPath.row].branch).uppercaseString
            
            Alamofire.request(.GET, (self.allEvents[indexPath.row].creatorImageURL)).responseData{ response in
                if let image = response.result.value {
                    cell.creatorImage.layer.masksToBounds = true
                    cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                    cell.creatorImage.image = UIImage(data: image)
                }
            }
            
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 5.0
            cell.layer.borderColor = UIColor.grayColor().CGColor
            
            return cell
        } else if collectionView == secondCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
            
            // Filling cell
            cell.date.text = popularEvents[indexPath.row].day + " " + months[Int(popularEvents[indexPath.row].month)! - 1] + ", " + popularEvents[indexPath.row].time
            cell.backgroundImage.image = UIImage(named: popularEvents[indexPath.row].branch)
            cell.creatorName.text = popularEvents[indexPath.row].creatorName
            cell.location.text = popularEvents[indexPath.row].location
            cell.location.adjustsFontSizeToFitWidth = true
            cell.branchName.text = (popularEvents[indexPath.row].branch).uppercaseString
            
            Alamofire.request(.GET, (self.popularEvents[indexPath.row].creatorImageURL)).responseData{ response in
                if let image = response.result.value {
                    cell.creatorImage.layer.masksToBounds = true
                    cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                    cell.creatorImage.image = UIImage(data: image)
                }
            }
            
            return cell
        } else if collectionView == thirdCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
            
            // Filling cell
            cell.date.text = favoriteEvents[indexPath.row].day + " " + months[Int(favoriteEvents[indexPath.row].month)! - 1] + ", " + favoriteEvents[indexPath.row].time
            cell.backgroundImage.image = UIImage(named: favoriteEvents[indexPath.row].branch)
            cell.creatorName.text = favoriteEvents[indexPath.row].creatorName
            cell.location.text = favoriteEvents[indexPath.row].location
            cell.location.adjustsFontSizeToFitWidth = true
            cell.branchName.text = (favoriteEvents[indexPath.row].branch).uppercaseString
            
            Alamofire.request(.GET, (self.favoriteEvents[indexPath.row].creatorImageURL)).responseData{ response in
                if let image = response.result.value {
                    cell.creatorImage.layer.masksToBounds = true
                    cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                    cell.creatorImage.image = UIImage(data: image)
                }
            }
            
            return cell
        } else if collectionView == fourthCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FavoriteSportCell", forIndexPath: indexPath) as! FavoriteSportCollectionViewCell
            
            cell.favSportImage.image = UIImage(named: branchs[indexPath.row])
            cell.favSportName.text = branchs[indexPath.row]
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView == firstCollectionView {
            let eventDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = allEvents[indexPath.row]
            self.presentViewController(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == secondCollectionView {
            let eventDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = popularEvents[indexPath.row]
            self.presentViewController(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == thirdCollectionView {
            let eventDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = favoriteEvents[indexPath.row]
            self.presentViewController(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == fourthCollectionView {
            
            let eventsVC = self.storyboard?.instantiateViewControllerWithIdentifier("EventsCollectionViewController") as! EventsCollectionViewController
            
            var events = [Event]()
            
            for i in 0..<allEvents.count {
                if allEvents[i].branch == branchs[indexPath.row] {events.insert(allEvents[i], atIndex: 0)  }
            }
            
            eventsVC.branchName = branchs[indexPath.row]
            eventsVC.events = events
            eventsVC.collectionView?.reloadData()
            
            self.showViewController(eventsVC, sender: self)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == firstCollectionView || collectionView == secondCollectionView || collectionView == thirdCollectionView {
            return CGSizeMake(screenSize.width-8, 180)
        }
        
        return CGSizeMake(screenSize.width, 100)
    }
    
    @IBAction func segmentChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            firstView.hidden = false
            secondView.hidden = true
            thirdView.hidden = true
            fourthView.hidden = true
            break
        case 1:
            firstView.hidden = true
            secondView.hidden = false
            thirdView.hidden = true
            fourthView.hidden = true
            break
        case 2:
            firstView.hidden = true
            secondView.hidden = true
            thirdView.hidden = false
            fourthView.hidden = true
            break
        case 3:
            firstView.hidden = true
            secondView.hidden = true
            thirdView.hidden = true
            fourthView.hidden = false
            break
        default:
            break
        }
    }
    
    //
    // Self created methods
    func retrieveAllEvents() {
        allEvents.removeAll()
        favoriteEvents.removeAll()
        
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
                    let locationLat = element.valueForKey("locationLat") as! String
                    let locationLon = element.valueForKey("locationLon") as! String
                    let maxJoinNumber = element.valueForKey("maxJoinNumber") as! String
                    let description = element.valueForKey("description") as! String
                    let time = element.valueForKey("time") as! String
                    let month = element.valueForKey("month") as! String
                    let day = element.valueForKey("day") as! String
                    let year = element.valueForKey("year") as! String
                    
                    let eventElement = Event(creatorID: creatorID, creatorImageURL: creatorImageURL, creatorName: creatorName, name: name, branch: branch, level: level, location: location, locationLat: locationLat, locationLon : locationLon, maxJoinNumber: maxJoinNumber, description: description, time: time, month: month, day: day, year: year, id: id)
                    
                    self.allEvents.insert(eventElement, atIndex: 0)
                }
                
                Async.main {
                    self.refreshControl1.endRefreshing()
                    self.firstCollectionView.reloadData()
                }
                
                REF_USERS.child((FIRAuth.auth()?.currentUser!.uid)!).child("favoriteSports").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if snapshot.exists() {
                        let postDict = snapshot.value as! Dictionary<String, String>

                        if postDict["First"] != "nil" { self.favoriteSports.insert(postDict["First"]!, atIndex: 0) }
                        if postDict["Second"] != "nil" { self.favoriteSports.insert(postDict["Second"]!, atIndex: 0) }
                        if postDict["Third"] != "nil" { self.favoriteSports.insert(postDict["Third"]!, atIndex: 0) }
                        if postDict["Fourth"] != "nil" { self.favoriteSports.insert(postDict["Fourth"]!, atIndex: 0) }
                        
                        for k in 0 ..< self.allEvents.count {
                            for j in 0 ..< self.favoriteSports.count {
                                if self.allEvents[k].branch == self.favoriteSports[j] {
                                    self.favoriteEvents.insert(self.allEvents[k], atIndex: 0)
                                }
                            }
                        }
                    }
                    
                    Async.main {
                        self.refreshControl1.endRefreshing()
                        self.thirdCollectionView.reloadData()
                    }
                })
            }
        })
    }
    
    func retrievePopularEvents() {
        popularEvents = [Event]()
        
        REF_POPULAR_EVENTS.observeSingleEventOfType(.Value , withBlock: { (snapshot) in
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
                    let locationLat = element.valueForKey("locationLat") as! String
                    let locationLon = element.valueForKey("locationLon") as! String
                    let maxJoinNumber = element.valueForKey("maxJoinNumber") as! String
                    let description = element.valueForKey("description") as! String
                    let time = element.valueForKey("time") as! String
                    let month = element.valueForKey("month") as! String
                    let day = element.valueForKey("day") as! String
                    let year = element.valueForKey("year") as! String
                    
                    let eventElement = Event(creatorID: creatorID, creatorImageURL: creatorImageURL, creatorName: creatorName, name: name, branch: branch, level: level, location: location, locationLat: locationLat, locationLon : locationLon, maxJoinNumber: maxJoinNumber, description: description, time: time, month: month, day: day, year: year, id: id)
                    
                    self.popularEvents.insert(eventElement, atIndex: 0)
                }
            }
            
            Async.main {
                self.refreshControl2.endRefreshing()
                self.secondCollectionView.reloadData()
            }
        })
    }
    
    func leftBarButtonItemTouchUpInside() {
        self.performSegueWithIdentifier("EventsToLoginSegue", sender: self)
    }
    
    func rightBarButtonItemTouchUpInside() {
        self.performSegueWithIdentifier("toChannelsSegue", sender: self)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let visibleCells = firstCollectionView.visibleCells() as? [EventCollectionViewCell] {
            for parallaxCell in visibleCells {
                let yOffset = ((firstCollectionView.contentOffset.y - parallaxCell.frame.origin.y) / 230) * 25
                parallaxCell.offset(CGPointMake(0.0, yOffset))
            }
        }
    }
}
