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

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScrollPagerDelegate, observeUser, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var noEventsToShowLabel: UILabel!
    
    @IBOutlet var profileImage: UIImageView!
    
    var settingsButton: UIBarButtonItem!
    
    @IBOutlet var profileName: UILabel!
    
    @IBOutlet var profileFollowers: UILabel!
    
    @IBOutlet var profileFollowing: UILabel!
    
    @IBOutlet var favoriteSportsCollectionView: UICollectionView!
    
    @IBOutlet var eventsCollectionView: UICollectionView!
    
    @IBOutlet var commentsTableView: UITableView!
    
    @IBOutlet var favoriteSportsHeight: NSLayoutConstraint!
    
    @IBOutlet var profileImageEditButton: UIButton!
    
    @IBOutlet var followersText: UILabel!
    
    @IBOutlet var followingText: UILabel!
    
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var scrollPager: ScrollPager!

    @IBOutlet var beeViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var verifiedImage: UIImageView!
    
    @IBOutlet var profileBioLabel: UILabel!
    
    @IBOutlet var bioChangeButton: UIButton!
    
    @IBOutlet var bioHeightConstraint: NSLayoutConstraint!
    
    var user : User? {
        didSet{
            self.setUser()
            self.getEventsIDs()
            self.getComments()
            
            if isViewLoaded { commentsTableView.reloadData() }
            
            if user?.favoriteSports != nil {
                self.favoriteSports = (user?.favoriteSports)!
                
                if self.isViewLoaded { self.favoriteSportsCollectionView.reloadData() }
            }
        }
    }
    
    // Tab bar = 0
    // Presented = 1
    var sender =  1
    var isFollowing = false
    var favoriteSports = [String]()
    var eventsArray = [Event]() {
        didSet{
            if isViewLoaded {
                if eventsArray.count == 0 {
                    self.noEventsToShowLabel.isHidden = false
                } else {
                    self.noEventsToShowLabel.isHidden = true
                }
            }
        }
    }
    var commentsArray = [Comment]()
    var eventDetailVC : EventDetailViewController!
    var favoriteSportPickerVC : FavoriteSportPickerViewController!
    var commentVC : CommentViewController!
    var popoverController : UIPopoverPresentationController!
    var settingsVC : SettingsTableViewController!
    var bioVC : BioViewController!
    var followeringVC : FollowerFollowingViewController!
    
    let imagePicker = UIImagePickerController()
    let backButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        followeringVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowerFollowingViewController") as? FollowerFollowingViewController
        bioVC = self.storyboard?.instantiateViewController(withIdentifier: "BioViewController") as! BioViewController
        settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
        commentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        eventDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        favoriteSportPickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteSportPickerViewController") as! FavoriteSportPickerViewController
        
        let eventNib = UINib(nibName: "EventCollectionViewCell", bundle: Bundle.main)
        eventsCollectionView.register(eventNib, forCellWithReuseIdentifier: "eventCell")

        self.view.layoutIfNeeded()

        scrollPager.delegate = self
        scrollPager.addSegmentsWithTitlesAndViews(segments: [
            ("My Events", eventsCollectionView),
            ("Comments", commentsTableView)
            ])

        settingsButton = UIBarButtonItem(image: UIImage(named: "Settings"), style: .plain, target: self, action: #selector(settingsButtonClicked))
        
        favoriteSportsHeight.constant = (screenSize.width / 5.0) + 10
        
        eventsCollectionView.alwaysBounceVertical = true
        commentsTableView.alwaysBounceVertical = true
        
        verifiedImage.alpha = 0
        profileImage.alpha = 0
        profileName.alpha = 0
        profileFollowers.alpha = 0
        profileFollowing.alpha = 0
        followersText.alpha = 0
        followingText.alpha = 0
        bioChangeButton.alpha = 0
        profileBioLabel.alpha = 0

        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.width/2.0
        profileImage.layer.borderColor = UIColor.gray.cgColor
        profileImage.layer.borderWidth = 1.0
        
        imagePicker.delegate = self
        
        favoriteSportsCollectionView.reloadData()
        eventsCollectionView.reloadData()
        commentsTableView.reloadData()
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        lpgr.delegate = self
        commentsTableView.addGestureRecognizer(lpgr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if eventsArray.count == 0 {
            self.noEventsToShowLabel.isHidden = false
        } else {
            self.noEventsToShowLabel.isHidden = true
        }
        
        if sender == 0 {
            if (user == nil) && (currentUser.instance.user != nil) { user = currentUser.instance.user }
        }
        
        if profileName.text == "Name" && user != nil { setUser() }
    }
    
    // MARK: - Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == eventsCollectionView {
            return eventsArray.count
        } else if collectionView == favoriteSportsCollectionView {
            if user?.id == FIRAuth.auth()?.currentUser?.uid {
                return 5
            } else {
                return favoriteSports.count+1
            }
        }
        
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if collectionView == eventsCollectionView {
            return CGSize(width: screenSize.width-8, height: 144)
        } else if collectionView == favoriteSportsCollectionView {
            return CGSize(width: (screenSize.width/5.0) - 6, height: (screenSize.width/5.0) - 6)
        }
        
        return CGSize(width: 0, height: 0)
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == eventsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
            
            cell.configureCell(event: eventsArray[indexPath.row])
            
            return cell
        } else if collectionView == favoriteSportsCollectionView {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "firstItem", for: indexPath)
                
                cell.layer.borderColor = UIColor(red: 65/255.0, green: 65/255.0, blue: 65/255.0, alpha: 1.0).cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = (screenSize.width/10.0) - 3
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteSportItem", for: indexPath) as! ProfileFavoriteSportCollectionViewCell
                
                if indexPath.row <= favoriteSports.count {
                    cell.image.image = UIImage(named: (favoriteSports[(indexPath as NSIndexPath).row - 1] + "Mini"))
                    cell.name.text = favoriteSports[(indexPath as NSIndexPath).row - 1]
                } else {
                    cell.image.image = UIImage(named: "Add2")
                    cell.name.text = "Add"
                }
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == eventsCollectionView {
            eventDetailVC.event = eventsArray[(indexPath as NSIndexPath).row]
            show(eventDetailVC, sender: self)
        } else if (collectionView == favoriteSportsCollectionView) && user != nil {
            if user?.id == FIRAuth.auth()?.currentUser?.uid {
                favoriteSportPickerVC.selectedBranchs = self.favoriteSports
                favoriteSportPickerVC.modalTransitionStyle = .crossDissolve
                present(favoriteSportPickerVC, animated: true, completion: nil)
            }
            
        }
    }
    
    
    // MARK: - Table View Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard user != nil else { return 0 }
        
        if user?.id == FIRAuth.auth()?.currentUser?.uid {
            return commentsArray.count
        }
        
        return commentsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == commentsArray.count { return 100 }
        
        return commentsArray[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == commentsArray.count && (user!.id != FIRAuth.auth()?.currentUser?.uid) {
            let cell = commentsTableView.dequeueReusableCell(withIdentifier: "addCommentCell", for: indexPath)
            
            return cell
        }
        
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! ProfileCommentTableViewCell
        
        cell.comment.text = commentsArray[indexPath.row].comment
        cell.date.text = commentsArray[indexPath.row].date
        cell.id = commentsArray[indexPath.row].id
        
        REF_USERS.child(commentsArray[indexPath.row].id).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let commmentedUser = User(snapshot: snapshot)
                
                cell.name.text = commmentedUser.displayName
                
                cell.userImage.kf.setImage(with: URL(string: commmentedUser.photoURL!))
            }
        
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (user?.id != FIRAuth.auth()?.currentUser?.uid) && (indexPath.row == commentsArray.count) {
            commentVC.modalPresentationStyle = UIModalPresentationStyle.popover
            commentVC.preferredContentSize = CGSize(width: screenSize.width-16, height: 250)
            commentVC.senderVC = self
            commentVC.user = self.user
            
            popoverController = commentVC.popoverPresentationController
            popoverController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            popoverController?.delegate = self
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = CGRect(x: 80, y: 80, width: 50, height: 50)
            present(commentVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Self created methods
    
    func getUser(userID: String) {
        REF_USERS.child(userID).observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.user = User(snapshot: snapshot)
            }
        })
    }
    
    func setUser() {
        if self.isViewLoaded && user != nil{
            profileName.text = self.user?.displayName
            
            profileBioLabel.text = self.user?.bio
            
            if user?.id == FIRAuth.auth()?.currentUser?.uid {
                navigationItem.rightBarButtonItem = settingsButton
            } else {
                navigationItem.rightBarButtonItem = nil
            }
            
            bioHeightConstraint.constant = (self.user?.bio.heightWithConstrainedWidth(profileName.frame.width, font: UIFont(name: "Open Sans", size: 11)!))!
            
            (self.user?.verified)! ? (verifiedImage.isHidden = false) : (verifiedImage.isHidden = true)
            
            self.user?.following != nil ? (self.profileFollowing.text = String(describing: (self.user?.following.count)!)) : (self.profileFollowing.text = "0")
            self.user?.followers != nil ? (self.profileFollowers.text = String(describing: (self.user?.followers.count)!)) : (self.profileFollowers.text = "0")
            
            self.profileImage.kf.setImage(with: URL(string: (user?.photoURL)!))
            
            UIView.animate(withDuration: 1, animations: { 
                self.profileImage.alpha = 1
                self.profileName.alpha = 1
                self.profileFollowers.alpha = 1
                self.profileFollowing.alpha = 1
                self.followersText.alpha = 1
                self.followingText.alpha = 1
                self.verifiedImage.alpha = 1
                self.bioChangeButton.alpha = 1
                self.profileBioLabel.alpha = 1
            })
            
            if user!.id != FIRAuth.auth()?.currentUser?.uid {
                profileImageEditButton.isHidden = true
                followButton.isHidden = false
                bioChangeButton.isHidden = true
                navigationItem.title = "Sportives"
            } else {
                profileImageEditButton.isHidden = false
                followButton.isHidden = true
                bioChangeButton.isHidden = false
                navigationItem.title = "My profile"
            }
            
            if let following = currentUser.instance.user?.following {
                for element in following {
                    if element == user!.id {
                        isFollowing = true
                        followButton.setTitle("following", for: UIControlState())
                        followButton.backgroundColor = primaryButtonColor
                        followButton.setTitleColor(UIColor.white, for: UIControlState())
                    }
                }
            }
        }
    }
    
    func getEventsIDs() {
        REF_USERS.child(user!.id).child("eventsCreated").observe(.value, with: { snapshot in

            if snapshot.exists() {
                
                let myEventsIDArray = Array((snapshot.value as! [String: String]).values)
                var myEventIDs = [String]()
                
                for element in myEventsIDArray {
                    myEventIDs.insert(element, at: 0)
                }
                
                self.eventsArray = [Event]()
                self.getEvents(myEventIDs)
            }
        })
    }
    
    func getEvents(_ events: [String]) {
        for element in 0...events.count-1 {
            REF_EVENTS.child(events[element]).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let eventElement = Event(snapshot: snapshot)
                    
                    self.eventsArray.append(eventElement)
                    
                    if element == events.count-1 && self.isViewLoaded { self.eventsCollectionView.reloadData() }
                }
            })
        }
    }
    
    func getComments() {
        REF_USERS.child(user!.id).child("comments").observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.commentsArray.removeAll()
                
                let comments = Array((snapshot.value as! Dictionary<String, AnyObject>).values)
                
                for element in comments {
                    let id = element["id"] as! String
                    let date = element["date"] as! String
                    let comment = element["comment"] as! String
                    let height = comment.heightWithConstrainedWidth(screenSize.width-76, font: UIFont(name: "Open Sans", size: 10)!)
                    
                    let newComment = Comment(id: id, date: date, comment: comment, height: height+80)
                    
                    self.commentsArray.insert(newComment, at: 0)
                }
                
                if self.isViewLoaded { self.commentsTableView.reloadData() }
            }
        })
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileImageEditButtonClicked(_ sender: AnyObject) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImage.image = image
        if let data = UIImageJPEGRepresentation(image, 0.2) {
            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            path = path + "/\(user!.id).jpg"
            do { try data.write(to: URL(fileURLWithPath: path), options: .atomic) }
            catch { print(error) }
            let url = URL(fileURLWithPath: path)
            REF_STORAGE.child(user!.id).putFile(url, metadata: nil, completion: { (meta, error) in
                if let meta = meta {
                    let url = meta.downloadURL()!
                    self.user!.photoURL = url.absoluteString
                    REF_USERS.child(self.user!.id).child("photoURL").setValue(url.absoluteString)
                } else { print(error) }
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func followButtonClicked(_ sender: AnyObject) {
        if !isFollowing {
            followButton.setTitle("following", for: UIControlState())
            followButton.backgroundColor = primaryButtonColor
            followButton.setTitleColor(UIColor.white, for: UIControlState())
            isFollowing = true
            
            currentUser.instance.user?.following.insert(user!.id, at: 0)
            
            REF_USERS.child(user!.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue(FIRAuth.auth()?.currentUser?.uid)
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user!.id).child("id").setValue(user!.id)
            
            let notifier = [
                "notification": (currentUser.instance.user?.displayName)! + " followed you!" ,
                "notificationConnection": (FIRAuth.auth()?.currentUser?.uid)!,
                "type": "newFollower"
            ]
            
            REF_NEW_NOTIFICATIONS.child(user!.id).setValue(true)
            REF_NOTIFICATIONS.child(user!.id).childByAutoId().setValue(notifier)
            
        } else {
            followButton.setTitle("follow", for: UIControlState())
            followButton.backgroundColor = UIColor.clear
            followButton.setTitleColor(primaryButtonColor, for: UIControlState())
            isFollowing = false
            
            for index in 0...(currentUser.instance.user?.following.count)!-1 {
                if user!.id == currentUser.instance.user?.following[index] {
                    currentUser.instance.user?.following.remove(at: index)
                    break
                }
            }
            
            REF_USERS.child(user!.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").removeValue()
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user!.id).child("id").removeValue()
        }
    }
    
    func settingsButtonClicked(_ sender: AnyObject) {
        
        settingsVC.modalPresentationStyle = UIModalPresentationStyle.popover
        settingsVC.preferredContentSize = CGSize(width: screenSize.width-16, height: 195)
        
        popoverController = settingsVC.popoverPresentationController
        popoverController?.permittedArrowDirections = .up
        popoverController?.delegate = self
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = CGRect(origin: CGPoint(x:screenSize.width-16 , y:-40), size: CGSize(width: 32, height: 32))
        present(settingsVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
     func scrollPager(scrollPager: ScrollPager, changedIndex: Int) {
        switch changedIndex {
        case 0:
            beeViewConstraint.constant = 0
            
            if eventsArray.count == 0 {
                noEventsToShowLabel.isHidden = false
            } else {
                noEventsToShowLabel.isHidden = true
            }
            break
        case 1:
            beeViewConstraint.constant = screenSize.width / 2.0
            noEventsToShowLabel.isHidden = true
            break
        default:
            break
        }
    }
    
    func userChanged() {
        if sender == 0 {
            self.user = currentUser.instance.user
        }
    }
    
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        let p = gestureRecognizer.location(in: self.commentsTableView)
        
        if let indexPath : IndexPath = (self.commentsTableView.indexPathForRow(at: p)){
            if let cell = self.commentsTableView.cellForRow(at: indexPath) as? ProfileCommentTableViewCell {
                if (user?.id == FIRAuth.auth()?.currentUser?.uid) || !(indexPath.row < commentsArray.count) { return }
                if cell.id != FIRAuth.auth()?.currentUser?.uid { return }
                
                if cell.name.text == currentUser.instance.user?.displayName {
                    print("Change comment")

                    let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
                    popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
                    popoverContent.preferredContentSize = CGSize(width: screenSize.width-16, height: 250)
                    popoverContent.senderVC = self
                    popoverContent.user = self.user
                    popoverContent.comment = cell.comment.text!
                    let popoverController = popoverContent.popoverPresentationController
                    popoverController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                    popoverController?.delegate = self
                    popoverController?.sourceView = self.view
                    popoverController?.sourceRect = CGRect(x: 80, y: 80, width: 50, height: 50)
                    present(popoverContent, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func bioChangeButtonClicked(_ sender: AnyObject) {
        bioVC.modalPresentationStyle = UIModalPresentationStyle.popover
        bioVC.preferredContentSize = CGSize(width: screenSize.width - 60, height: 195)
        bioVC.senderVC = self
        bioVC.oldBio = profileBioLabel.text!
        
        popoverController = bioVC.popoverPresentationController
        popoverController?.permittedArrowDirections = .any
        popoverController?.delegate = self
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = bioChangeButton.frame
        present(bioVC, animated: true, completion: nil)
    }

    @IBAction func followersButtonClicked(_ sender: AnyObject) {
        followeringVC.userIDs = (self.user?.followers)!
        followeringVC.headerText = "Followers"
        followeringVC.users.removeAll()
        
        show(followeringVC, sender: self)
    }
    
    @IBAction func followingButtonClicked(_ sender: AnyObject) {
        followeringVC.userIDs = (self.user?.following)!
        followeringVC.headerText = "Following"
        followeringVC.users.removeAll()
        
        show(followeringVC, sender: self)
    }
    
    
}
