//
//  PastEventsViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 29.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import Async
import Alamofire

class PastEventsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var myEventsCollectionView: UICollectionView!
    
    var eventsArray = [Event]()
    
    internal var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle:nil)
        
        myEventsCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "eventCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if eventsArray.count == 0 { getMyEventsIDs() }
    }
    
    //
    // CollectionView Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = myEventsCollectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
        
        // Filling cell
        cell.date.text = eventsArray[indexPath.row].day + " " + months[Int(eventsArray[indexPath.row].month)! - 1] + ", " + eventsArray[indexPath.row].time
        cell.backgroundImage.image = UIImage(named: eventsArray[indexPath.row].branch)
        cell.creatorName.text = eventsArray[indexPath.row].creatorName
        cell.location.text = eventsArray[indexPath.row].location
        cell.branchName.text = (eventsArray[indexPath.row].branch).uppercaseString
        
        Alamofire.request(.GET, (self.eventsArray[indexPath.row].creatorImageURL)).responseData{ response in
            if let image = response.result.value {
                cell.creatorImage.layer.masksToBounds = true
                cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                cell.creatorImage.image = UIImage(data: image)
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let eventDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
        eventDetailVC.event = eventsArray[indexPath.row]
        self.presentViewController(eventDetailVC, animated: true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenSize.width, 180)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let visibleCells = myEventsCollectionView.visibleCells() as? [EventCollectionViewCell] {
            for parallaxCell in visibleCells {
                let yOffset = ((myEventsCollectionView.contentOffset.y - parallaxCell.frame.origin.y) / 230) * 25
                parallaxCell.offset(CGPointMake(0.0, yOffset))
            }
        }
    }
    
    //
    // Self created methods
    func getMyEventsIDs() {
        REF_USERS.child(user!.id).child("eventsCreated").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if snapshot.exists() {
                let myEventsIDArray = Array((snapshot.value as! [String: String]).values)
                var myEventIDs = [String]()
                
                for element in myEventsIDArray {
                    myEventIDs.insert(element, atIndex: 0)
                }
                
                self.eventsArray = [Event]()
                self.getMyEvents(myEventIDs)
            }
        })
    }
    
    func getMyEvents(events: [String]) {
        for element in events {
            REF_EVENTS.child(element).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                if snapshot.exists() {
                    let dict = NSDictionary(dictionary: snapshot.value as! [String : AnyObject])
                    
                    let id = dict.valueForKey("id") as! String
                    let creatorID = dict.valueForKey("creatorID") as! String
                    let creatorImageURL = dict.valueForKey("creatorImageURL") as! String
                    let creatorName = dict.valueForKey("creatorName") as! String
                    let name = dict.valueForKey("name") as! String
                    let branch = dict.valueForKey("branch") as! String
                    let level = dict.valueForKey("level") as! String
                    let location = dict.valueForKey("location") as! String
                    let locationLat = dict.valueForKey("locationLat") as! String
                    let locationLon = dict.valueForKey("locationLon") as! String
                    let maxJoinNumber = dict.valueForKey("maxJoinNumber") as! String
                    let description = dict.valueForKey("description") as! String
                    let time = dict.valueForKey("time") as! String
                    let month = dict.valueForKey("month") as! String
                    let day = dict.valueForKey("day") as! String
                    let year = dict.valueForKey("year") as! String
                    
                    let eventElement = Event(creatorID: creatorID, creatorImageURL: creatorImageURL, creatorName: creatorName, name: name, branch: branch, level: level, location: location, locationLat : locationLat, locationLon : locationLon, maxJoinNumber: maxJoinNumber, description: description, time: time, month: month, day: day, year: year, id: id)
                    
                    self.eventsArray.insert(eventElement, atIndex: 0)
                }
                
                Async.main {
                    self.myEventsCollectionView.reloadData()
                }
            })
        }
    }
}
