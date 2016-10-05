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

}
