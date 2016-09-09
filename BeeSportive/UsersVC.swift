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

class UsersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users = [User]()
    var filteredUsers = [User]()
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        FTIndicator.showProgressWithmessage("Loading", userInteractionEnable: false)
        let nib = UINib(nibName: "UserCell", bundle:nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "userCell")
        REF_USERS.observeEventType(.Value, withBlock: { (snapshot) in
            self.users.removeAll()
            self.filteredUsers.removeAll()
            for snap in snapshot.children {
                let user = User(snapshot: snap as! FIRDataSnapshot)
                self.users.append(user)
                self.collectionView.reloadData()
            }
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching { return filteredUsers.count }
        else { return users.count }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCell", forIndexPath: indexPath) as? UserCell {
            if isSearching { cell.configureCell(filteredUsers[indexPath.row]) }
            else { cell.configureCell(users[indexPath.row])  }
            return cell
        } else { return UICollectionViewCell() }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(160, 187)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        let function = Functions()
        if isSearching { function.getProfilePage(filteredUsers[indexPath.row].id, vc: self) }
        else { function.getProfilePage(users[indexPath.row].id, vc: self) }
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
        }; collectionView.reloadData()
    }

}
