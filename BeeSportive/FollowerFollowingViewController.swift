//
//  FollowerFollowingViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 23.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class FollowerFollowingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var headerText = ""
    var userIDs = [String]()
    var users = [User]()
    var followedUsers = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "UserCell", bundle:nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "userCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        headerLabel.text = headerText
        followedUsers = (currentUser.instance.user?.following)!
        
        retrieveUsers()
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
        
        let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        viewController5.getUser(userID: users[indexPath.row].id)
        
        self.present(viewController5, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func retrieveUsers() {
        self.users.removeAll()
        
        for element in userIDs {
            REF_USERS.child(element).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    self.users.append(User(snapshot: snapshot))
                    
                    self.collectionView.reloadData()
                }
            })
        }

    }
}
