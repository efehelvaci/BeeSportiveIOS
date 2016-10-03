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

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScrollPagerDelegate {
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var settingsButton: UIButton!
    
    @IBOutlet var profileName: UILabel!
    
    @IBOutlet var profileFollowers: UILabel!
    
    @IBOutlet var profileFollowing: UILabel!
    
    @IBOutlet var favoriteSportsCollectionView: UICollectionView!
    
    @IBOutlet var eventsCollectionView: UICollectionView!
    
    @IBOutlet var commentsTableView: UITableView!
    
    @IBOutlet var commentTextField: UITextField!
    
    @IBOutlet var favoriteSportsHeight: NSLayoutConstraint!
    
    @IBOutlet var profileImageEditButton: UIButton!
    
    @IBOutlet var followersText: UILabel!
    
    @IBOutlet var followingText: UILabel!
    
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var scrollPager: ScrollPager!

    @IBOutlet var beeViewConstraint: NSLayoutConstraint!
    
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
        
        profileImage.alpha = 0
        profileName.alpha = 0
        profileFollowers.alpha = 0
        profileFollowing.alpha = 0
        followersText.alpha = 0
        followingText.alpha = 0

        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.width/2.0
        profileImage.layer.borderColor = UIColor.gray.cgColor
        profileImage.layer.borderWidth = 1.0
        
        imagePicker.delegate = self
        
        favoriteSportsCollectionView.reloadData()
        eventsCollectionView.reloadData()
        commentsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sender == 0 ? (backButton.isHidden = true) : (backButton.isHidden = false)
        
        if profileName.text == "null" && user != nil { setUser() }
    }
    
    // MARK: - Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == eventsCollectionView {
            return eventsArray.count
        } else if collectionView == favoriteSportsCollectionView {
            return favoriteSports.count + 1
        }
        
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if collectionView == eventsCollectionView {
            return CGSize(width: screenSize.width-8, height: 180)
        } else if collectionView == favoriteSportsCollectionView {
            return CGSize(width: (screenSize.width/5.0)-16, height: (screenSize.width/5.0)-16)
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
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteSportItem", for: indexPath) as! ProfileFavoriteSportCollectionViewCell
                
                cell.image.image = UIImage(named: favoriteSports[(indexPath as NSIndexPath).row - 1])?.af_imageRoundedIntoCircle()
                cell.name.text = favoriteSports[(indexPath as NSIndexPath).row - 1]
                
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
        }
    }
    
    
    
    // MARK: - Table View Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == commentsArray.count { return 100 }
        
        return commentsArray[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == commentsArray.count {
            let cell = commentsTableView.dequeueReusableCell(withIdentifier: "addCommentCell", for: indexPath)
            
            return cell
        }
        
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! ProfileCommentTableViewCell
        
        cell.comment.text = commentsArray[(indexPath as NSIndexPath).row].comment
        cell.date.text = commentsArray[(indexPath as NSIndexPath).row].date
        
        REF_USERS.child(commentsArray[(indexPath as NSIndexPath).row].id).observeSingleEvent(of: .value, with: { snapshot in
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
    
    // MARK: - Text Field
    
    func animateTextField(_ textField: UITextField, up: Bool)
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
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func commentEditingBegin(_ sender: AnyObject) {
        let inputView = sender as! UITextField
        inputView.becomeFirstResponder()
        self.animateTextField(sender as! UITextField, up: true)
    }
    
    
    @IBAction func commentSend(_ sender: AnyObject) {
        
        let inputView = sender as! UITextField
        inputView.resignFirstResponder()
        self.animateTextField(sender as! UITextField, up: false)
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd.M.yy, HH:mm"
        let date = dateFormatter.string(from: Date())
        
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
        REF_USERS.child(userID).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.user = User(snapshot: snapshot)
                
                REF_USERS.child(userID).child("adminOptions").observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        let data = snapshot.value as! Dictionary <String, AnyObject>
                        
                        if let verified = (data["verified"] as? Bool) {
                            self.user?.verified = verified
                        }
                    }
                })
                
                self.setUser()
                self.getEventsIDs()
                self.getComments()
            }
        })
    
        REF_USERS.child(userID).child("favoriteSports").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.favoriteSports.removeAll()
                
                let postDict = snapshot.value as! Dictionary<String, String>
                
                if postDict["First"] != "nil" { self.favoriteSports.insert(postDict["First"]!, at: 0) }
                if postDict["Second"] != "nil" { self.favoriteSports.insert(postDict["Second"]!, at: 0) }
                if postDict["Third"] != "nil" { self.favoriteSports.insert(postDict["Third"]!, at: 0) }
                if postDict["Fourth"] != "nil" { self.favoriteSports.insert(postDict["Fourth"]!, at: 0) }
                
                if self.isViewLoaded { self.favoriteSportsCollectionView.reloadData() }
                
            }
        })
    }
    
    func setUser() {
        if self.isViewLoaded {
            profileName.text = self.user?.displayName
            
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
            })
            
            if user!.id != FIRAuth.auth()?.currentUser?.uid {
                profileImageEditButton.isHidden = true
                settingsButton.isHidden = true
                followButton.isHidden = false
            } else {
                profileImageEditButton.isHidden = false
                settingsButton.isHidden = false
                followButton.isHidden = true
            }
            
            for element in followingUsers.instance.users {
                if element.id == user!.id {
                    isFollowing = true
                    followButton.setTitle("unfollow", for: UIControlState())
                }
            }
            
        }
    }
    
    func getEventsIDs() {
        REF_USERS.child(user!.id).child("eventsCreated").observeSingleEvent(of: .value, with: { snapshot in
            
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
        REF_USERS.child(user!.id).child("comments").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.commentsArray.removeAll()
                
                let comments = Array((snapshot.value as! Dictionary<String, AnyObject>).values)
                
                for element in comments {
                    let id = element["id"] as! String
                    let date = element["date"] as! String
                    let comment = element["comment"] as! String
                    let height = comment.heightWithConstrainedWidth(screenSize.width-76, font: UIFont(name: "Helvetica", size: 14)!)
                    
                    let newComment = Comment(id: id, date: date, comment: comment, height: height+60)
                    
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
            
            followingUsers.instance.users.insert(user!, at: 0)
            REF_USERS.child(user!.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue(FIRAuth.auth()?.currentUser?.uid)
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user!.id).child("id").setValue(user!.id)
            
        } else {
            followButton.setTitle("follow", for: UIControlState())
            isFollowing = false
            
            for index in 0...followingUsers.instance.users.count-1 {
                if user!.id == followingUsers.instance.users[index].id {
                    followingUsers.instance.users.remove(at: index)
                    break
                }
            }
            
            REF_USERS.child(user!.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").removeValue()
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user!.id).child("id").removeValue()
        }
    }
    
     func scrollPager(scrollPager: ScrollPager, changedIndex: Int) {
        switch changedIndex {
        case 0:
            beeViewConstraint.constant = 0
            break
        case 1:
            beeViewConstraint.constant = screenSize.width / 2.0
            break
        default:
            break
        }
    }
}
