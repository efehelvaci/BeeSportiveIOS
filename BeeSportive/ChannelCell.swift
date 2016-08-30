//
//  ChannelCell.swift
//  Chatmates
//
//  Created by Doruk Gezici on 04/07/16.
//  Copyright © 2016 Doruk Gezici. All rights reserved.
//

import UIKit

class ChannelCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var sender: UILabel!

//    func configureCell(channel: Channel) {
//        self.channel = channel
//        title.text = channel.title
//        date.text = channel.lastMessage[Constants.LastMessageKeys.date]
//        lastMessage.text = channel.lastMessage[Constants.LastMessageKeys.message]
//        if let senderId = channel.lastMessage[Constants.LastMessageKeys.senderId] {
//            if senderId == "" { sender.text = "" }
//            else { sender.text = channel.lastSenderDisplayName}
//        }
//        if let url = channel.photoURL {
//            img.hnk_setImageFromURL(url)
//        }
//    }

}
