//
//  EventCollectionViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 17.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var creatorName: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var creatorImage: UIImageView!
    @IBOutlet var branchName: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var eventName: UILabel!
    @IBOutlet var capacity: UILabel!
    @IBOutlet var verifiedImage: UIImageView!
    @IBOutlet var blackWhiteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var user : User!
    
    func configureCell(event: Event) {
        clipsToBounds = false
        
        self.creatorImage.image = UIImage()
        self.creatorName.text = ""
        self.verifiedImage.isHidden = true
        
        // Hex code: CCCCCC
        self.layer.borderColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 1.0
        
        blackWhiteView.alpha = 0
        
        REF_USERS.child(event.creatorID).observeSingleEvent(of: .value, with : { snapshot in
            if snapshot.exists() {
                self.user = User(snapshot: snapshot)
                
                self.creatorName.text = self.user.displayName
                self.creatorName.isHidden = false
                
                self.user.verified ? (self.verifiedImage.isHidden = false) : (self.verifiedImage.isHidden = true)

                let url = URL(string: self.user.photoURL!)
                self.creatorImage.kf.setImage(with: url)
            }
        })
        
        if event.creatorID == FIRAuth.auth()?.currentUser?.uid {
            // Hex code: FEE941
            self.layer.borderColor = UIColor(red: 254/255.0, green: 233/255.0, blue: 65/255.0, alpha: 1.0).cgColor
            self.layer.borderWidth = 2.0
        }
        if event.isSponsored {
            self.layer.borderColor = primaryButtonColor.cgColor
            self.layer.borderWidth = 3.0
        }
        
        self.date.text = event.day + " " + months[Int(event.month)! - 1] + ", " + event.dayName + ", " + event.time
        self.backgroundImage.image = UIImage(named: event.branch)
        self.location.text = event.location
        self.location.adjustsFontSizeToFitWidth = true
        self.branchName.text = (event.branch).lowercased()
        self.eventName.text = event.name
        self.capacity.text = "\(event.participants.count)/" + (event.maxJoinNumber) + " Free Spots"
        
        if event.isPast {
            blackWhiteView.alpha = 0.6
            capacity.text = "Event past!"
        }
    }
}
