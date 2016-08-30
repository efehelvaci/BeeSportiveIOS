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

class PastEventsViewController: UIViewController {

    @IBOutlet var myEventsCollectionView: UICollectionView!
    
    let user = (FIRAuth.auth()?.currentUser)!
    let databaseRef = FIRDatabase.database().reference()
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var eventsArray = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle:nil)
        
        myEventsCollectionView.registerNib(nibName, forCellWithReuseIdentifier: "eventCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getMyEventsIDs()
    }
    
    //
    // CollectionView Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return self.eventsArray.count
        return eventsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = myEventsCollectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
        
        // Filling cell
        cell.backgroundImage.image = UIImage(named: eventsArray[indexPath.row].branch)
        cell.creatorName.text = eventsArray[indexPath.row].creatorName
        cell.dateDay.text = eventsArray[indexPath.row].day
        cell.dateMonth.text =  months[Int(eventsArray[indexPath.row].month)! - 1]
        cell.location.text = eventsArray[indexPath.row].location
        cell.time.text = eventsArray[indexPath.row].time
        
        Alamofire.request(.GET, (self.eventsArray[indexPath.row].creatorImageURL)).responseData{ response in
            if let image = response.result.value {
                cell.creatorImage.layer.masksToBounds = true
                cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                cell.creatorImage.image = UIImage(data: image)
            }
        }

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
        return CGSizeMake(UIScreen.mainScreen().bounds.width, 130)
    }
    
    //
    // Self created methods
    func getMyEventsIDs() {
        databaseRef.child("users").child(user.uid).child("eventsCreated").observeEventType(.Value, withBlock: { snapshot in
            
            if snapshot.exists() {
                let myEventsIDArray = Array((snapshot.value as! [String: String]).values)
                var myEventIDs = [String]()
                
                for element in myEventsIDArray {
                    myEventIDs.insert(element, atIndex: 0)
                }
                
                self.getMyEvents(myEventIDs)
            }
        })
    }
    
    func getMyEvents(events: [String]) {
        for element in events {
            databaseRef.child("events").child(element).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                if snapshot.exists() {
                    let dict = NSDictionary(dictionary: snapshot.value as! [String : AnyObject])
                    
                    let creatorID = dict.valueForKey("creatorID") as! String
                    let creatorImageURL = dict.valueForKey("creatorImageURL") as! String
                    let creatorName = dict.valueForKey("creatorName") as! String
                    let name = dict.valueForKey("name") as! String
                    let branch = dict.valueForKey("branch") as! String
                    let level = dict.valueForKey("level") as! String
                    let location = dict.valueForKey("location") as! String
                    let maxJoinNumber = dict.valueForKey("maxJoinNumber") as! String
                    let description = dict.valueForKey("description") as! String
                    let time = dict.valueForKey("time") as! String
                    let month = dict.valueForKey("month") as! String
                    let day = dict.valueForKey("day") as! String
                    let year = dict.valueForKey("year") as! String
                    
                    let eventElement = Event(creatorID: creatorID, creatorImageURL: creatorImageURL, creatorName: creatorName, name: name, branch: branch, level: level, location: location, maxJoinNumber: maxJoinNumber, description: description, time: time, month: month, day: day, year: year)
                    
                    self.eventsArray.insert(eventElement, atIndex: 0)
                    
                    Async.main {
                        self.myEventsCollectionView.reloadData()
                    }
                }
            })
        }
    }
}
