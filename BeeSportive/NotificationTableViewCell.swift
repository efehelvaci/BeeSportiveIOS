//
//  NotificationTableViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 5.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var notificationImage: UIImageView!
    @IBOutlet var notificationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(notification: Notification) {
        notificationLabel.text = notification.notification
        
        switch notification.notificationType {
        case .general:
            notificationImage.image = UIImage(named: "Bee")
            break
        case .joinRequestAccepted:
            notificationImage.image = UIImage(named: "AcceptedToEvent")
            break
        case .newFollower:
            notificationImage.image = UIImage(named: "NewFollower")
            break
        case .incomingJoinRequest:
            notificationImage.image = UIImage(named: "JoinRequest")
            break
        default:
            break
        }
    }

}
