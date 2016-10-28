//
//  UserCell.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 06/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import Async

protocol whatHappensAfterFollow {
    func afterFollowingUser(activeUser: User)
    func afterUnfollowingUser(activeUser: User)
}

class UserCell: UICollectionViewCell {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var verifiedImage: UIImageView!
    
    var following = false
    var user : User!
    var delegate : whatHappensAfterFollow!

    func configureCell(_ user: User) {
        self.user = user
        
        displayName.isHidden = true
        img.isHidden = true
        
        if following{
            if followButton.currentTitle != "following" {
                followButton.setTitle("following", for: UIControlState())
                followButton.backgroundColor = primaryButtonColor
                followButton.setTitleColor(UIColor.white, for: UIControlState())
            }
        } else {
            if followButton.currentTitle != "follow" {
                followButton.setTitle("follow", for: UIControlState())
                followButton.backgroundColor = UIColor.clear
                followButton.setTitleColor(primaryButtonColor, for: UIControlState())
            }
        }
        
        user.verified ? (verifiedImage.isHidden = false) : (verifiedImage.isHidden = true)
        
        displayName.text = user.displayName
        displayName.isHidden = false
        
        Async.main{
            if let urlStr = user.photoURL {
                let imgURL = URL(string: urlStr)!
                
                self.img.kf.setImage(with: imgURL)
                self.img.layer.masksToBounds = true
                self.img.layer.cornerRadius = self.img.frame.width / 2.0
                self.img.isHidden = false
            }
        }
        
        if user.id == FIRAuth.auth()?.currentUser?.uid {
            followButton.isHidden = true
        } else {
            followButton.isHidden = false
        }
    }

    @IBAction func followButtonClicked(_ sender: AnyObject) {
        guard (user != nil) else {
            return
        }
        
        if !following {
            followButton.setTitle("following", for: UIControlState())
            followButton.backgroundColor = primaryButtonColor
            followButton.setTitleColor(UIColor.white, for: UIControlState())
            following = true
         
            if delegate != nil {
                self.delegate.afterFollowingUser(activeUser: self.user)
            }
            
            currentUser.instance.user?.following.insert(user!.id, at: 0)
            
            REF_USERS.child(user.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue(FIRAuth.auth()?.currentUser?.uid)
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user.id).child("id").setValue(user.id)
            
            let notifier = [
                "notification": (currentUser.instance.user?.displayName)! + " followed you!" ,
                "notificationConnection": (FIRAuth.auth()?.currentUser?.uid)!,
                "type": "newFollower"
            ]
            
            REF_NOTIFICATIONS.child(user.id).childByAutoId().setValue(notifier)
        } else {
            followButton.setTitle("follow", for: UIControlState())
            followButton.backgroundColor = UIColor.clear
            followButton.setTitleColor(primaryButtonColor, for: UIControlState())
            following = false
            
            if delegate != nil {
                self.delegate.afterUnfollowingUser(activeUser: self.user)
            }
            
            for index in 0...(currentUser.instance.user?.following.count)!-1 {
                if user!.id == currentUser.instance.user?.following[index] {
                    currentUser.instance.user?.following.remove(at: index)
                    break
                }
            }
            
            REF_USERS.child(user.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").removeValue()
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user.id).child("id").removeValue()
        }
    }
    
}
