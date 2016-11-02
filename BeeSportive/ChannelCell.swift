//
//  ChannelCell.swift
//  Chatmates
//
//  Created by Doruk Gezici on 04/07/16.
//  Copyright © 2016 Doruk Gezici. All rights reserved.
//

import UIKit
import Firebase

class ChannelCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!

    func configureCell(_ channel: Channel) {
        self.isHidden = true
        self.lastMessage.text = channel.lastMessage["message"]
        self.date.text = channel.lastMessage["date"]

        REF_EVENTS.child(channel.id).observeSingleEvent(of: .value, with: { snapshot in
            if let title = snapshot.childSnapshot(forPath: "name").value as? String {
                self.title.text = title
            }
            if let branch = snapshot.childSnapshot(forPath: "branch").value as? String {
                self.img.image = UIImage(named: (branch + "Mini"))
            }

            self.isHidden = false
        })
    }

}
