//
//  ChannelCell.swift
//  Chatmates
//
//  Created by Doruk Gezici on 04/07/16.
//  Copyright © 2016 Doruk Gezici. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class ChannelCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var sender: UILabel!

    func configureCell(_ channel: Channel) {
        self.isHidden = true
        self.lastMessage.text = channel.lastMessage["message"]
        self.date.text = channel.lastMessage["date"]
        if channel.lastMessage["senderId"]! != "" {
            REF_USERS.child(channel.lastMessage["senderId"]!).child("displayName").observe(.value, with: { (snapshot) in
                if let displayName = snapshot.value as? String {
                    self.sender.text = displayName
                }
            })
        }
        REF_EVENTS.child(channel.id).observe(.value, with: { snapshot in
            if let title = snapshot.childSnapshot(forPath: "name").value as? String {
                self.title.text = title
            }
            if let branch = snapshot.childSnapshot(forPath: "branch").value as? String {
                self.backgroundView = UIImageView(image: UIImage(named: branch))
                self.backgroundView?.contentMode = .scaleAspectFill
                self.backgroundView?.alpha = 0.8
                let layer = UIView(frame: CGRect(origin: self.contentView.bounds.origin, size: self.contentView.bounds.size))
                layer.backgroundColor = UIColor.black
                layer.alpha = 0.3
                layer.isUserInteractionEnabled = false
                self.backgroundView?.addSubview(layer)
            }
            if let imgURLstr = snapshot.childSnapshot(forPath: "creatorImageURL").value as? String {

                Alamofire.request(imgURLstr).responseImage(completionHandler: { response in
                    if let image = response.result.value {
                        self.img.layer.masksToBounds = true
                        self.img.layer.cornerRadius = self.img.frame.width / 2.0
                        self.img.image = image
                    }
                })
            }
            self.isHidden = false
        })
    }

}
