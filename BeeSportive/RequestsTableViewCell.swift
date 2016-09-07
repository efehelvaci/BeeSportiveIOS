//
//  RequestsTableViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 1.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RequestsTableViewCell: UITableViewCell {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userImage: UIImageView!
    
    var requesterID : String?
    var eventID : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = userImage.frame.width/2.0
        userImage.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func declineButtonClicked(sender: AnyObject) {
        REF_EVENTS.child(eventID!).child("requested").child(requesterID!).removeValue()
    }
    
 
    @IBAction func acceptButtonClicked(sender: AnyObject) {
        REF_EVENTS.child(eventID!).child("requested").child(requesterID!).removeValue()
        REF_EVENTS.child(eventID!).child("participants").child(requesterID!).setValue("accepted")
    }
}
