//
//  ProfileViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 26.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import Async
import Haneke

class ProfileViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var settingsButton: UIButton!
    
    @IBOutlet var profileName: UILabel!
    
    @IBOutlet var profileFollowers: UILabel!
    
    @IBOutlet var profileFollowing: UILabel!
    
    @IBOutlet var favoriteSportsCollectionView: UICollectionView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var segmentBeeEventsLabel: UILabel!
    
    @IBOutlet var segmentCommentsLabel: UILabel!
    
    @IBOutlet var segmentFirstView: UIView!
    
    @IBOutlet var segmentSecondView: UIView!
    
    @IBOutlet var eventsCollectionView: UICollectionView!
    
    @IBOutlet var commentsTableView: UITableView!
    
    @IBOutlet var commentTextField: UITextField!
    
    @IBOutlet var favoriteSportsHeight: NSLayoutConstraint!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var user : User?
    
    var favoriteSports = [String]()
    
    var eventsArray = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.width/2.0
        profileImage.layer.borderColor = UIColor.grayColor().CGColor
        profileImage.layer.borderWidth = 1.0
        
        favoriteSportsHeight.constant = (screenSize.width / 5.0) + 10
        
        scrollView.alwaysBounceVertical = false
        
        let eventNib = UINib(nibName: "EventCollectionViewCell", bundle: nil)
        eventsCollectionView.registerNib(eventNib, forCellWithReuseIdentifier: "eventCell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getUser((FIRAuth.auth()?.currentUser?.uid)!)
    }
    
    // MARK: - Collection View Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == eventsCollectionView {
            return eventsArray.count
        } else if collectionView == favoriteSportsCollectionView {
            return favoriteSports.count + 1
        }
        
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == eventsCollectionView {
            return CGSizeMake(screenSize.width-8, 180)
        } else if collectionView == favoriteSportsCollectionView {
            return CGSizeMake((screenSize.width/5.0)-16, (screenSize.width/5.0)-16)
        }
        
        return CGSizeMake(0, 0)
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == eventsCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCell", forIndexPath: indexPath) as! EventCollectionViewCell
            
            cell.date.text = eventsArray[indexPath.row].day + " " + months[Int(eventsArray[indexPath.row].month)! - 1] + ", " + eventsArray[indexPath.row].time
            cell.backgroundImage.image = UIImage(named: eventsArray[indexPath.row].branch)
            cell.creatorName.text = eventsArray[indexPath.row].creatorName
            cell.location.text = eventsArray[indexPath.row].location
            cell.location.adjustsFontSizeToFitWidth = true
            cell.branchName.text = (eventsArray[indexPath.row].branch).uppercaseString
            cell.creatorImage.hnk_setImageFromURL(NSURL(string: self.eventsArray[indexPath.row].creatorImageURL)!, placeholder: UIImage(), format: nil, failure: nil, success: { image in
                cell.creatorImage.layer.masksToBounds = true
                cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                cell.creatorImage.image = image
            })
            
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 5.0
            cell.layer.borderColor = UIColor.grayColor().CGColor
            
            
            return cell
        } else if collectionView == favoriteSportsCollectionView {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("firstItem", forIndexPath: indexPath)
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("favoriteSportItem", forIndexPath: indexPath) as! ProfileFavoriteSportCollectionViewCell
                
                cell.image.image = UIImage(named: favoriteSports[indexPath.row - 1])
                cell.name.text = favoriteSports[indexPath.row - 1]
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: - Table View Delegate Methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentsTableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! ProfileCommentTableViewCell
        
        return cell
    }
    
    // MARK: - Segmented Control
    
    @IBAction func segmentChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            segmentFirstView.hidden = false
            segmentSecondView.hidden = true
            break
        case 1:
            segmentFirstView.hidden = true
            segmentSecondView.hidden = false
            break
        default:
            break
        }
    }
    
    // MARK: - Text Field
    
    @IBAction func commentSend(sender: AnyObject) {
        print ("LOLLOL")
    }
    
    // MARK: - Self created methods
    
    func getUser(userID: String) {
        REF_USERS.child(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                self.user = User(snapshot: snapshot)
                
                self.setUser()
                self.getEventsIDs()
            }
        })
        
        REF_USERS.child(userID).child("favoriteSports").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                let postDict = snapshot.value as! Dictionary<String, String>
                
                if postDict["First"] != "nil" { self.favoriteSports.insert(postDict["First"]!, atIndex: 0) }
                if postDict["Second"] != "nil" { self.favoriteSports.insert(postDict["Second"]!, atIndex: 0) }
                if postDict["Third"] != "nil" { self.favoriteSports.insert(postDict["Third"]!, atIndex: 0) }
                if postDict["Fourth"] != "nil" { self.favoriteSports.insert(postDict["Fourth"]!, atIndex: 0) }
                
                self.favoriteSportsCollectionView.reloadData()
            }
        })
    }
    
    func setUser() {
        profileName.text = self.user?.displayName
        profileImage.hnk_setImageFromURL(NSURL(string: (user?.photoURL)!)!, placeholder: UIImage(), format: nil, failure: nil, success: { image in
            self.profileImage.image = image
        })
    }
    
    func getEventsIDs() {
        REF_USERS.child(user!.id).child("eventsCreated").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if snapshot.exists() {
                let myEventsIDArray = Array((snapshot.value as! [String: String]).values)
                var myEventIDs = [String]()
                
                for element in myEventsIDArray {
                    myEventIDs.insert(element, atIndex: 0)
                }
                
                self.eventsArray = [Event]()
                self.getEvents(myEventIDs)
            }
        })
    }
    
    func getEvents(events: [String]) {
        for element in 0...events.count-1 {
            REF_EVENTS.child(events[element]).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if snapshot.exists() {
                    let eventElement = Event(snapshot: snapshot)
                    
                    self.eventsArray.insert(eventElement, atIndex: 0)
                    
                    if element == events.count-1 { self.eventsCollectionView.reloadData() }
                }
            })
        }
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
