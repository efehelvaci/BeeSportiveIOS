//
//  UsersVC.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 06/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import FTIndicator

class UsersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, observeFollowing {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var followingIDs = [String]()
    var users = [User]()
    var filteredUsers = [User]()
    var isSearching = false
    var followedUsers = [User]()
    var verifiedUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        followingUsers.instance.delegate = self
        followedUsers = followingUsers.instance.users
        
        FTIndicator.showProgressWithmessage("Loading", userInteractionEnable: false)
        
        let nib = UINib(nibName: "UserCell", bundle:nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "userCell")
        
        REF_USERS.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.users.removeAll()
            
            for snap in snapshot.children {
                let user = User(snapshot: snap as! FIRDataSnapshot)
                
                if user.id == FIRAuth.auth()?.currentUser?.uid { continue }
                
                if user.verified { self.verifiedUsers.append(user) }
                
                self.users.append(user)
            }
            
            self.collectionView.reloadData()
            FTIndicator.dismissProgress()
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if isSearching {
            return filteredUsers.count
        } else {
            return verifiedUsers.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCell", forIndexPath: indexPath) as? UserCell {
            cell.following = false
            cell.alpha = 0
            
            if isSearching {
                for element in followedUsers {
                    if element.id == filteredUsers[indexPath.row].id{
                        cell.following = true
                    }
                }
                
                cell.configureCell(filteredUsers[indexPath.row])
            } else {
                for element in followedUsers {
                    if element.id == verifiedUsers[indexPath.row].id {
                        cell.following = true
                    }
                }
                
                cell.configureCell(users[indexPath.row])
            }
            
            UIView.animateWithDuration(0.5, animations: {
                cell.alpha = 1
            })
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(screenSize.width-6, 60)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let viewController5 = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        
        isSearching ? (viewController5.getUser(filteredUsers[indexPath.row].id)) : (viewController5.getUser(users[indexPath.row].id))
        
        self.presentViewController(viewController5, animated: true, completion: nil)

    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            let key = searchBar.text!.capitalizedString
            filteredUsers = users.filter({$0.displayName.rangeOfString(key) != nil})
        }
        
        collectionView.reloadData()
    }
    
    func followingsChanged() {
        followedUsers = followingUsers.instance.users
    }

}
