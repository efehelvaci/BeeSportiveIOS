//
//  ChannelCell.swift
//  Chatmates
//
//  Created by Doruk Gezici on 04/07/16.
//  Copyright © 2016 Doruk Gezici. All rights reserved.
//

import UIKit
import Firebase
import Haneke

class ChannelCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var sender: UILabel!

    func configureCell(channel: Channel) {
        self.hidden = true
        self.lastMessage.text = channel.lastMessage["message"]
        self.date.text = channel.lastMessage["date"]
        if channel.lastMessage["senderId"]! != "" {
            REF_USERS.child(channel.lastMessage["senderId"]!).child("displayName").observeEventType(.Value, withBlock: { (snapshot) in
                if let displayName = snapshot.value as? String {
                    self.sender.text = displayName
                }
            })
        }
        REF_EVENTS.child(channel.id).observeEventType(.Value, withBlock: { snapshot in
            if let title = snapshot.childSnapshotForPath("name").value as? String {
                self.title.text = title
            }
            if let branch = snapshot.childSnapshotForPath("branch").value as? String {
                self.backgroundView = UIImageView(image: UIImage(named: branch))
                self.backgroundView?.contentMode = .ScaleAspectFill
                self.backgroundView?.alpha = 0.8
                let layer = UIView(frame: CGRect(origin: self.contentView.bounds.origin, size: self.contentView.bounds.size))
                layer.backgroundColor = UIColor.blackColor()
                layer.alpha = 0.3
                layer.userInteractionEnabled = false
                self.backgroundView?.addSubview(layer)
            }
            if let imgURLstr = snapshot.childSnapshotForPath("creatorImageURL").value as? String {
                let imgURL = NSURL(string: imgURLstr)!
                self.img.hnk_setImageFromURL(imgURL, placeholder: UIImage(), format: nil, failure: nil, success: { (image) in
                    self.img.layer.masksToBounds = true
                    self.img.layer.cornerRadius = self.img.frame.width / 2.0
                    self.img.image = image
                })
            }
            self.hidden = false
        })
    }

}
