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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(event: Event) {
        self.clipsToBounds = false
        
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
        
        self.date.text = event.day + " " + months[Int(event.month)! - 1] + ", " + event.time
        self.backgroundImage.image = UIImage(named: event.branch)
        self.location.text = event.location
        self.location.adjustsFontSizeToFitWidth = true
        self.branchName.text = (event.branch).lowercased()
        self.eventName.text = event.name
        self.capacity.text = "1/" + (event.maxJoinNumber) + " Free Spots"
        

    }
    
    func offset(_ offset: CGPoint) {
        backgroundImage.frame = self.backgroundImage.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    
}
