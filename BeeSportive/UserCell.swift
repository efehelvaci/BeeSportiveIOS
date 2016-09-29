//
//  UserCell.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 06/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FTIndicator
import Haneke
import Firebase

class UserCell: UICollectionViewCell {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet var followButton: UIButton!
    
    var following = false
    var user : User!

    func configureCell(user: User) {
        self.user = user
        
        if following{
            if followButton.currentTitle != "unfollow" { followButton.setTitle("unfollow", forState: .Normal) }
        } else {
            if followButton.currentTitle != "follow" { followButton.setTitle("follow", forState: .Normal) }
        }
        
        self.hidden = true
        displayName.text = user.displayName
        if let urlStr = user.photoURL {
            let imgURL = NSURL(string: urlStr)!
            self.img.hnk_setImageFromURL(imgURL, placeholder: UIImage(), format: nil, failure: nil, success: { (image) in
                self.img.layer.masksToBounds = true
                self.img.layer.cornerRadius = self.img.frame.width / 2.0
                self.img.image = image
                FTIndicator.dismissProgress()
            })
        }
        self.hidden = false
    }

    @IBAction func followButtonClicked(sender: AnyObject) {
        guard (user != nil) else {
            return
        }
        
        if !following {
            followButton.setTitle("unfollow", forState: .Normal)
            following = true
            
            followingUsers.instance.users.insert(user, atIndex: 0)
            REF_USERS.child(user.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue(FIRAuth.auth()?.currentUser?.uid)
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user.id).child("id").setValue(user.id)
        } else {
            followButton.setTitle("follow", forState: .Normal)
            following = false
            
            for index in 0...followingUsers.instance.users.count-1 {
                if user.id == followingUsers.instance.users[index].id {
                    followingUsers.instance.users.removeAtIndex(index)
                    break
                }
            }
            
            REF_USERS.child(user.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").removeValue()
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user.id).child("id").removeValue()
        }
    }
    
}
