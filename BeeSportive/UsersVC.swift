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

class UsersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, observeUser {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var followingIDs = [String]()
    var users = [User]()
    var filteredUsers = [User]()
    var isSearching = false
    var followedUsers = [String]()
    var verifiedUsers = [User]()
    
    let backButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        currentUser.instance.delegate1 = self
        if currentUser.instance.user?.following != nil { followedUsers = (currentUser.instance.user?.following)! }
        
        let nib = UINib(nibName: "UserCell", bundle:nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "userCell")
        
        REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                FTIndicator.showProgressWithmessage("Loading...", userInteractionEnable: true)
                
                self.users.removeAll()
                
                for snap in snapshot.children {
                    let user = User(snapshot: snap as! FIRDataSnapshot)
                    
                    if user.id == FIRAuth.auth()?.currentUser?.uid { continue }
                    
                    if user.verified { self.verifiedUsers.append(user) }
                    
                    self.users.append(user)
                }
                
                self.collectionView.reloadData()
                
                FTIndicator.dismissProgress()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentUser.instance.user?.following != nil { followedUsers = (currentUser.instance.user?.following)! }
        self.collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FTIndicator.dismissProgress()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if isSearching {
            return filteredUsers.count
        } else {
            return verifiedUsers.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as? UserCell {
            cell.following = false
            cell.alpha = 0
            
            if isSearching {
                for element in followedUsers {
                    if element == filteredUsers[(indexPath as NSIndexPath).row].id{
                        cell.following = true
                    }
                }
                
                cell.configureCell(filteredUsers[(indexPath as NSIndexPath).row])
            } else {
                for element in followedUsers {
                    if element == verifiedUsers[(indexPath as NSIndexPath).row].id {
                        cell.following = true
                    }
                }
                
                cell.configureCell(verifiedUsers[(indexPath as NSIndexPath).row])
            }
            
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
        
        let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController

        isSearching ? (viewController5.getUser(userID: filteredUsers[indexPath.row].id)) : (viewController5.getUser(userID: verifiedUsers[indexPath.row].id))
        
        show(viewController5, sender: self)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            let key = searchBar.text!.lowercased()
            filteredUsers = users.filter({$0.displayName.lowercased().range(of: key) != nil})
        }
        
        collectionView.reloadData()
    }
    
    func userChanged() {
        followedUsers = (currentUser.instance.user?.following)!
    }

}
