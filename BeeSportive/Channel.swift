//
//  Channel.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 30/08/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation
import Firebase

class Channel {

    var id: String!
    var title: String!
    var lastMessage: Dictionary<String, String> = ["message":"There are no messages yet!", "senderId":"", "date":""]
    var lastSenderID: String!
    var photoURL: NSURL?

  init(snapshot: FIRDataSnapshot) {
        self.id = snapshot.key
//        if let data = snapshot.value as? Dictionary<String, AnyObject> {
//            self.title = data["title"] as! String
//            if let lastMessage = data["lastMessage"] as? Dictionary<String, String> {
//                self.lastMessage = lastMessage
//                if let senderId = lastMessage[Constants.LastMessageKeys.senderId] {
//                    REF_USERS.child(senderId).child("displayName").observeEventType(.Value, withBlock: { (snapshot) in
//                        if let displayName = snapshot.value as? String {
//                            self.lastSenderDisplayName = displayName
//                        }
//                    })
//                }
//            }
//            if let urlStr = data["photoURL"] as? String {
//                let url = NSURL(string: urlStr)!
//                photoURL = url
//                Shared.imageCache.fetch(URL: url)
//            }
//        } else { id = "channel"; title = "Channel" }
    }

}
