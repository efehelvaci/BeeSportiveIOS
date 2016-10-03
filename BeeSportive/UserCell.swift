//
//  UserCell.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 06/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FTIndicator
import Firebase
import Alamofire
import AlamofireImage

class UserCell: UICollectionViewCell {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet var followButton: UIButton!
    
    var following = false
    var user : User!

    func configureCell(_ user: User) {
        self.user = user
        
        if following{
            if followButton.currentTitle != "unfollow" { followButton.setTitle("unfollow", for: UIControlState()) }
        } else {
            if followButton.currentTitle != "follow" { followButton.setTitle("follow", for: UIControlState()) }
        }
        
        self.isHidden = true
        displayName.text = user.displayName
        if let urlStr = user.photoURL {
            let imgURL = URL(string: urlStr)!
            
            Alamofire.request(imgURL).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    self.img.layer.masksToBounds = true
                    self.img.layer.cornerRadius = self.img.frame.width / 2.0
                    self.img.image = image
                    FTIndicator.dismissProgress()
                }
            })
        }
        self.isHidden = false
    }

    @IBAction func followButtonClicked(_ sender: AnyObject) {
        guard (user != nil) else {
            return
        }
        
        if !following {
            followButton.setTitle("unfollow", for: UIControlState())
            following = true
            
            followingUsers.instance.users.insert(user, at: 0)
            REF_USERS.child(user.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue(FIRAuth.auth()?.currentUser?.uid)
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user.id).child("id").setValue(user.id)
        } else {
            followButton.setTitle("follow", for: UIControlState())
            following = false
            
            for index in 0...followingUsers.instance.users.count-1 {
                if user.id == followingUsers.instance.users[index].id {
                    followingUsers.instance.users.remove(at: index)
                    break
                }
            }
            
            REF_USERS.child(user.id).child("followers").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").removeValue()
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").child(user.id).child("id").removeValue()
        }
    }
    
}
