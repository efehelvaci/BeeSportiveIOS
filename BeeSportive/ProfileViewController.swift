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

class ProfileViewController: UIViewController, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    @IBOutlet var profileImageEditButton: UIButton!
    
    @IBOutlet var followersText: UILabel!
    
    @IBOutlet var followingText: UILabel!
    
    @IBOutlet var followButton: UIButton!
    
    var user : User?
    
    // Tab bar = 0
    // Presented = 1
    var sender =  1
    
    var isFollowing = false
    
    var favoriteSports = [String]()
    
    var eventsArray = [Event]()
    
    var commentsArray = [Comment]()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.alpha = 0
        profileName.alpha = 0
        profileFollowers.alpha = 0
        profileFollowing.alpha = 0
        followersText.alpha = 0
        followingText.alpha = 0

        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.width/2.0
        profileImage.layer.borderColor = UIColor.grayColor().CGColor
        profileImage.layer.borderWidth = 1.0
        
        imagePicker.delegate = self
        
        favoriteSportsCollectionView.reloadData()
        eventsCollectionView.reloadData()
        commentsTableView.reloadData()
        
        favoriteSportsHeight.constant = (screenSize.width / 5.0) + 10
        
        scrollView.alwaysBounceVertical = false
        
        let eventNib = UINib(nibName: "EventCollectionViewCell", bundle: nil)
        eventsCollectionView.registerNib(eventNib, forCellWithReuseIdentifier: "eventCell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sender == 0 ? (backButton.hidden = true) : (backButton.hidden = false)
        
        if profileName.text == "null" && user != nil { setUser() }
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == eventsCollectionView {
            let eventDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = eventsArray[indexPath.row]
            self.presentViewController(eventDetailVC, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Table View Delegate Methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return commentsArray[indexPath.row].height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentsTableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! ProfileCommentTableViewCell
        
        cell.comment.text = commentsArray[indexPath.row].comment
        cell.date.text = commentsArray[indexPath.row].date
        
        REF_USERS.child(commentsArray[indexPath.row].id).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                let commmentedUser = User(snapshot: snapshot)
                
                cell.name.text = commmentedUser.displayName
                cell.userImage.hnk_setImageFromURL(NSURL(string: commmentedUser.photoURL!)!, placeholder: UIImage(), format: nil, failure: nil, success: { image in
                    cell.userImage.image = image
                })
            }
        
        })
        
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
    
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -180
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    @IBAction func commentEditingBegin(sender: AnyObject) {
        let inputView = sender as! UITextField
        inputView.becomeFirstResponder()
        self.animateTextField(sender as! UITextField, up: true)
    }
    
    
    @IBAction func commentSend(sender: AnyObject) {
        
        let inputView = sender as! UITextField
        inputView.resignFirstResponder()
        self.animateTextField(sender as! UITextField, up: false)
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd.M.yy, HH:mm"
        let date = dateFormatter.stringFromDate(NSDate())
        
        let commentText = commentTextField.text!
        commentTextField.text = ""
        
        let comment = [
            "id" : (FIRAuth.auth()?.currentUser?.uid)!,
            "date" : date,
            "comment" : commentText
        ]
        
        REF_USERS.child(user!.id).child("comments").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(comment)
        
        getComments()
    }
    
    // MARK: - Self created methods
    
    func getUser(userID: String) {
        REF_USERS.child(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                self.user = User(snapshot: snapshot)
                
//                REF_USERS.child(userID).child("adminOptions").observeSingleEventOfType(.Value, withBlock: { snapshot in
//                    if snapshot.exists() {
//                        let data = snapshot.value as! Dictionary <String, AnyObject>
//                        
//                        if let verified = (data["verified"] as? Bool) {
//                            self.user?.verified = verified
//                        }
//                    }
//                })
                
                self.setUser()
                self.getEventsIDs()
                self.getComments()
            }
        })
        
        REF_USERS.child(userID).child("favoriteSports").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                self.favoriteSports.removeAll()
                
                let postDict = snapshot.value as! Dictionary<String, String>
                
                if postDict["First"] != "nil" { self.favoriteSports.insert(postDict["First"]!, atIndex: 0) }
                if postDict["Second"] != "nil" { self.favoriteSports.insert(postDict["Second"]!, atIndex: 0) }
                if postDict["Third"] != "nil" { self.favoriteSports.insert(postDict["Third"]!, atIndex: 0) }
                if postDict["Fourth"] != "nil" { self.favoriteSports.insert(postDict["Fourth"]!, atIndex: 0) }
                
                if self.isViewLoaded() { self.favoriteSportsCollectionView.reloadData() }
                
            }
        })
    }
    
    func setUser() {
        if self.isViewLoaded() {
            profileName.text = self.user?.displayName
            profileImage.hnk_setImageFromURL(NSURL(string: (user?.photoURL)!)!, placeholder: UIImage(), format: nil, failure: nil, success: { image in
                self.profileImage.image = image
            })
            
            UIView.animateWithDuration(1, animations: { 
                self.profileImage.alpha = 1
                self.profileName.alpha = 1
                self.profileFollowers.alpha = 1
                self.profileFollowing.alpha = 1
                self.followersText.alpha = 1
                self.followingText.alpha = 1
            })
            
            if user!.id != FIRAuth.auth()?.currentUser?.uid {
                profileImageEditButton.hidden = true
                settingsButton.hidden = true
                followButton.hidden = false
            } else {
                profileImageEditButton.hidden = false
                settingsButton.hidden = false
                followButton.hidden = true
            }
            
            for element in followingUsers.instance.users {
                if element.id == user!.id {
                    isFollowing = true
                    followButton.setTitle("unfollow", forState: .Normal)
                }
            }
            
        }
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
                    
                    if element == events.count-1 && self.isViewLoaded() { self.eventsCollectionView.reloadData() }
                }
            })
        }
    }
    
    func getComments() {
        REF_USERS.child(user!.id).child("comments").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                self.commentsArray.removeAll()
                
                let comments = Array((snapshot.value as! Dictionary<String, AnyObject>).values)
                
                for element in comments {
                    let id = element["id"] as! String
                    let date = element["date"] as! String
                    let comment = element["comment"] as! String
                    let height = comment.heightWithConstrainedWidth(screenSize.width-76, font: UIFont(name: "Helvetica", size: 14)!)
                    
                    let newComment = Comment(id: id, date: date, comment: comment, height: height+60)
                    
                    self.commentsArray.insert(newComment, atIndex: 0)
                }
                
                if self.isViewLoaded() { self.commentsTableView.reloadData() }
            }
        })
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func profileImageEditButtonClicked(sender: AnyObject) {
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImage.image = image
        if let data = UIImageJPEGRepresentation(image, 0.2) {
            var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            path = path.stringByAppendingString("/\(user!.id).jpg")
            do { try data.writeToFile(path, options: .DataWritingAtomic) }
            catch { print(error) }
            let url = NSURL(fileURLWithPath: path)
            REF_STORAGE.child(user!.id).putFile(url, metadata: nil, completion: { (meta, error) in
                if let meta = meta {
                    let url = meta.downloadURL()!
                    self.user!.photoURL = url.absoluteString
                    REF_USERS.child(self.user!.id).child("photoURL").setValue(url.absoluteString)
                } else { print(error) }
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    @IBAction func followButtonClicked(sender: AnyObject) {
        if !isFollowing {
            followButton.setTitle("unfollow", forState: .Normal)
            isFollowing = true
            
            followingUsers.instance.users.insert(user!, atIndex: 0)
            REF_USERS.child(user!.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue(FIRAuth.auth()?.currentUser?.uid)
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user!.id).child("id").setValue(user!.id)
            
        } else {
            followButton.setTitle("follow", forState: .Normal)
            isFollowing = false
            
            for index in 0...followingUsers.instance.users.count-1 {
                if user!.id == followingUsers.instance.users[index].id {
                    followingUsers.instance.users.removeAtIndex(index)
                    break
                }
            }
            
            REF_USERS.child(user!.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").removeValue()
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user!.id).child("id").removeValue()
        }
    }
    
    
}
