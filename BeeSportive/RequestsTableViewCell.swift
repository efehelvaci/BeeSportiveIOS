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
    var delegate : RequestsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = userImage.frame.width/2.0
        userImage.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func deleteUserFromTable() {
        for i in 0 ..< delegate!.users.count {
            if requesterID! == delegate!.users[i].id {
                delegate!.users.remove(at: i)
                delegate!.tableView.reloadData()
            }
        }
        
        if delegate!.users.count == 0 { delegate!.dismiss(animated: true, completion: nil) }
    }
    
    @IBAction func declineButtonClicked(_ sender: AnyObject) {
        REF_EVENTS.child(eventID!).child("requested").child(requesterID!).removeValue()
        deleteUserFromTable()
    }
    
 
    @IBAction func acceptButtonClicked(_ sender: AnyObject) {
        REF_EVENTS.child(eventID!).child("requested").child(requesterID!).removeValue()
        REF_EVENTS.child(eventID!).child("participants").child(requesterID!).child("id").setValue(requesterID!)
        REF_EVENTS.child(eventID!).child("participants").child(requesterID!).child("status").setValue("accepted")
        deleteUserFromTable()
    }
}
