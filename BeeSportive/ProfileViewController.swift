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
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScrollPagerDelegate, observeUser, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var noEventsToShowLabel: UILabel!
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var settingsButton: UIButton!
    
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
    
    @IBOutlet var navBarTitle: UILabel!
    
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
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eventNib = UINib(nibName: "EventCollectionViewCell", bundle: Bundle.main)
        eventsCollectionView.register(eventNib, forCellWithReuseIdentifier: "eventCell")

        self.view.layoutIfNeeded()

        scrollPager.delegate = self
        scrollPager.addSegmentsWithTitlesAndViews(segments: [
            ("Past Events", eventsCollectionView),
            ("Comments", commentsTableView)
            ])
        
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
        settingsButton.alpha = 0
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
            backButton.isHidden = true
        } else {
            backButton.isHidden = false
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
                    cell.image.image = UIImage(named: favoriteSports[(indexPath as NSIndexPath).row - 1])?.af_imageRoundedIntoCircle()
                    cell.name.text = favoriteSports[(indexPath as NSIndexPath).row - 1]
                } else {
                    cell.image.image = UIImage(named: "Add2")?.af_imageRoundedIntoCircle()
                    cell.name.text = "Add"
                }
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == eventsCollectionView {
            let eventDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = eventsArray[(indexPath as NSIndexPath).row]
            self.present(eventDetailVC, animated: true, completion: nil)
        } else if (collectionView == favoriteSportsCollectionView) && user != nil {
            if user?.id == FIRAuth.auth()?.currentUser?.uid {
                let favoriteSportPickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteSportPickerViewController") as! FavoriteSportPickerViewController
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
                
                Alamofire.request(commmentedUser.photoURL!).responseImage(completionHandler: { response in
                    if let image = response.result.value {
                        cell.userImage.image = image
                    }
                })
            }
        
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (user?.id != FIRAuth.auth()?.currentUser?.uid) && (indexPath.row == commentsArray.count) {
            let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverContent.preferredContentSize = CGSize(width: screenSize.width-16, height: 250)
            popoverContent.senderVC = self
            popoverContent.user = self.user
            let popoverController = popoverContent.popoverPresentationController
            popoverController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            popoverController?.delegate = self
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = CGRect(x: 80, y: 80, width: 50, height: 50)
            present(popoverContent, animated: true, completion: nil)
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
            
            bioHeightConstraint.constant = (self.user?.bio.heightWithConstrainedWidth(profileName.frame.width, font: UIFont(name: "Open Sans", size: 11)!))!
            
            (self.user?.verified)! ? (verifiedImage.isHidden = false) : (verifiedImage.isHidden = true)
            
            self.user?.following != nil ? (self.profileFollowing.text = String(describing: (self.user?.following.count)!)) : (self.profileFollowing.text = "0")
            self.user?.followers != nil ? (self.profileFollowers.text = String(describing: (self.user?.followers.count)!)) : (self.profileFollowers.text = "0")
            
            Alamofire.request((user?.photoURL)!).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    self.profileImage.image = image
                }
            })
            
            UIView.animate(withDuration: 1, animations: { 
                self.profileImage.alpha = 1
                self.profileName.alpha = 1
                self.profileFollowers.alpha = 1
                self.profileFollowing.alpha = 1
                self.followersText.alpha = 1
                self.followingText.alpha = 1
                self.verifiedImage.alpha = 1
                self.bioChangeButton.alpha = 1
                self.settingsButton.alpha = 1
                self.profileBioLabel.alpha = 1
            })
            
            if user!.id != FIRAuth.auth()?.currentUser?.uid {
                profileImageEditButton.isHidden = true
                settingsButton.isHidden = true
                followButton.isHidden = false
                bioChangeButton.isHidden = true
                navBarTitle.text = "Sportives"
            } else {
                profileImageEditButton.isHidden = false
                settingsButton.isHidden = false
                followButton.isHidden = true
                bioChangeButton.isHidden = false
                navBarTitle.text = "My profile"
            }
            
            if let following = currentUser.instance.user?.following {
                for element in following {
                    if element == user!.id {
                        isFollowing = true
                        followButton.setTitle("unfollow", for: UIControlState())
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
            followButton.setTitle("unfollow", for: UIControlState())
            isFollowing = true
            
            currentUser.instance.user?.following.insert(user!.id, at: 0)
            
            REF_USERS.child(user!.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue(FIRAuth.auth()?.currentUser?.uid)
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user!.id).child("id").setValue(user!.id)
            
        } else {
            followButton.setTitle("follow", for: UIControlState())
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
    
    @IBAction func settingsButtonClicked(_ sender: AnyObject) {

        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverContent.preferredContentSize = CGSize(width: screenSize.width-16, height: 195)
        let popoverController = popoverContent.popoverPresentationController
        popoverController?.permittedArrowDirections = .any
        popoverController?.delegate = self
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = CGRect(origin: CGPoint(x:self.settingsButton.frame.origin.x , y:self.settingsButton.frame.origin.y+15), size: self.settingsButton.frame.size)
        present(popoverContent, animated: true, completion: nil)
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
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "BioViewController") as! BioViewController
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverContent.preferredContentSize = CGSize(width: screenSize.width - 60, height: 195)
        popoverContent.senderVC = self
        let popoverController = popoverContent.popoverPresentationController
        popoverController?.permittedArrowDirections = .any
        popoverController?.delegate = self
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = bioChangeButton.frame
        present(popoverContent, animated: true, completion: nil)
    }
    
}
