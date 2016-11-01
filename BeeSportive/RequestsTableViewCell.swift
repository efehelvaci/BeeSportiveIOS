//
//  RequestsTableViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 1.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Async

class RequestsTableViewCell: UITableViewCell {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userImage: UIImageView!
    
    var requesterID : String?
    var eventID : String?
    var delegate : RequestsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        userImage.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func deleteUserFromTable(accepted: Bool) {
        for i in 0 ..< delegate!.users.count {
            if requesterID! == delegate!.users[i].id {
                if accepted { delegate!.senderVC?.event.participants.append(requesterID!) }
                
                Async.background{
                    self.delegate!.tableView.beginUpdates()
                    
                    self.delegate!.users.remove(at: i)
                    let indexPath = IndexPath(item: i, section: 0)
                    
                    self.delegate!.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    Async.main(after: 0.1, { _ in
                        self.delegate!.tableView.endUpdates()
                        if self.delegate!.users.count == 0 { self.delegate!.dismiss(animated: true, completion: nil) }
                        self.delegate!.tableView.isUserInteractionEnabled = true
                    })
                }

                break
            }
        }
    }
    
    @IBAction func declineButtonClicked(_ sender: AnyObject) {
        delegate!.tableView.isUserInteractionEnabled = false
        REF_EVENTS.child(eventID!).child("requested").child(requesterID!).removeValue()
        deleteUserFromTable(accepted: false)
    }
    
 
    @IBAction func acceptButtonClicked(_ sender: AnyObject) {
        delegate!.tableView.isUserInteractionEnabled = false
        REF_EVENTS.child(eventID!).child("requested").child(requesterID!).removeValue()
        REF_EVENTS.child(eventID!).child("participants").child(requesterID!).child("id").setValue(requesterID!)
        REF_EVENTS.child(eventID!).child("participants").child(requesterID!).child("status").setValue("accepted")
        REF_USERS.child(requesterID!).child("joinedEvents").child(eventID!).setValue(eventID!)
        
        let notifier = [
            "notification": "You are accepted to the event: '" + delegate!.senderVC!.event.name + "'. Now you can chat with other sportives participating!" ,
            "notificationConnection": delegate!.senderVC!.event.id,
            "type": "joinRequestAccepted"
        ]
        
        REF_NEW_NOTIFICATIONS.child(requesterID!).setValue(true)
        REF_NOTIFICATIONS.child(requesterID!).childByAutoId().setValue(notifier)
        
        deleteUserFromTable(accepted: true)
    }
}
