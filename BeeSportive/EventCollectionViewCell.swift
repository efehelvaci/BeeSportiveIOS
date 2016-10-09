//
//  EventCollectionViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 17.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
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
    
    func configureCell(event: Event) {
        clipsToBounds = false
        
        // Hex code: CCCCCC
        self.layer.borderColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0).cgColor
        self.layer.borderWidth = 1.0
        
        creatorImage.isHidden = true
        blackWhiteView.alpha = 0
        
        REF_USERS.child(event.creatorID).observeSingleEvent(of: .value, with : { snapshot in
            if snapshot.exists() {
                let user = User(snapshot: snapshot)
                
                self.creatorName.text = user.displayName
                self.creatorName.isHidden = false
                
                user.verified ? (self.verifiedImage.isHidden = false) : (self.verifiedImage.isHidden = true)
                
                Alamofire.request(user.photoURL!).responseImage(completionHandler: { response in
                    if let image = response.result.value {
                        self.creatorImage.image = image
                        self.creatorImage.isHidden = false
                    }
                })
            }
        })
        
        if event.creatorID == FIRAuth.auth()?.currentUser?.uid {
            // Hex code: FEE941
            self.layer.borderColor = UIColor(red: 254/255.0, green: 233/255.0, blue: 65/255.0, alpha: 1.0).cgColor
            self.layer.borderWidth = 2.0
            self.layer.cornerRadius = 1.0
        }
        
        self.date.text = event.day + " " + months[Int(event.month)! - 1] + ", " + event.time
        self.backgroundImage.image = UIImage(named: event.branch)
        self.location.text = event.location
        self.location.adjustsFontSizeToFitWidth = true
        self.branchName.text = (event.branch).lowercased()
        self.eventName.text = event.name
        self.capacity.text = "\(event.participants.count)/" + (event.maxJoinNumber) + " Free Spots"
        
        if event.fullDate != nil {
            if (event.fullDate?.isLessThanDate(dateToCompare: Date()))! {
                blackWhiteView.alpha = 0.5
                capacity.text = "Event past!"
            }
        }
    }
    
    func offset(_ offset: CGPoint) {
        backgroundImage.frame = self.backgroundImage.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    
}
