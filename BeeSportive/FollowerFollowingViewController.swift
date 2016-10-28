//
//  FollowerFollowingViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 23.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FTIndicator

class FollowerFollowingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, whatHappensAfterFollow {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var headerText = ""
    var userIDs = [String]()
    var users = [User]()
    var followedUsers = [String]()
    var profileVC : ProfileViewController!
    
    let backButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        profileVC = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController

        let nib = UINib(nibName: "UserCell", bundle:nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "userCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = headerText
        followedUsers = (currentUser.instance.user?.following)!
        
        collectionView.reloadData()
        retrieveUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FTIndicator.dismissProgress()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as? UserCell {
            cell.following = false
            cell.alpha = 0
            cell.delegate = self
            
            for element in followedUsers {
                if element == users[indexPath.row].id {
                    cell.following = true
                }
            }
            
            cell.configureCell(users[indexPath.row])
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.alpha = 1
            })
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: screenSize.width-6, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        profileVC.getUser(userID: users[indexPath.row].id)
        
        show(profileVC, sender: self)
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func retrieveUsers() {
        self.users.removeAll()
        var counter = 0
        FTIndicator.showProgressWithmessage("Loading...")
        
        for element in userIDs {
            REF_USERS.child(element).observeSingleEvent(of: .value, with: { snapshot in
                
                counter = counter + 1
                
                if snapshot.exists() {
                    self.users.append(User(snapshot: snapshot))
                }
                
                if self.userIDs.count == counter {
                    self.collectionView.reloadData()
                    FTIndicator.dismissProgress()
                }
            })
        }
        
        if userIDs.count == 0 {
            FTIndicator.dismissProgress()
            FTIndicator.showInfo(withMessage: "No users to show.")
        }
    }
    
    
    // MARK: - Whats Happens After Follow or Unfollow protocol
    func afterUnfollowingUser(activeUser: User) {
        if let removeThisID = self.followedUsers.index(of: activeUser.id) {
            self.followedUsers.remove(at: removeThisID)
        }
    }
    
    func afterFollowingUser(activeUser: User) {
        self.followedUsers.append(activeUser.id)
    }
}
