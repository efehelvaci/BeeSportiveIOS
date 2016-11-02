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

    let dateFormatter = DateFormatter()
    var id: String!
    var title: String!
    var lastMessage: Dictionary<String, String> = ["message":"There are no messages yet!", "senderId":"", "date":""]
    var photoURL: URL?
    var date = Date().addDays(daysToAdd: -1000)

    init(snapshot: FIRDataSnapshot) {
        self.id = snapshot.key
        
        self.dateFormatter.dateFormat = "HH.mm - dd.M.yy"
        
        REF_EVENTS.child(snapshot.key).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            if let name = snapshot.value as? String {
                self.title = name
            } else { self.title = "Channel" }
        })
        if let data = snapshot.value as? Dictionary<String, AnyObject> {
            if let lastMessage = data["lastMessage"] as? Dictionary<String, String> {
                self.lastMessage = lastMessage
                
                if let dateString = lastMessage["date"] {
                    if let validDate = dateFormatter.date(from: dateString) {
                        self.date = validDate
                    } else if let validDate2 = dateFormatter.date(from: dateString) {
                        self.date = validDate2
                    }
                }
            }
            if let urlStr = data["photoURL"] as? String {
                let url = URL(string: urlStr)
                self.photoURL = url
            }
        } else {
            REF_CHANNELS.child(snapshot.key).child("title").setValue(self.title)
            REF_CHANNELS.child(snapshot.key).child("lastMessage").setValue(self.lastMessage)
        }
    }

}
