//
//  Event.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 16.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation
import Firebase

class Event {
    let id : String
    let creatorID : String
    let name : String
    let branch : String
    let level : String
    let location : String
    let locationLat : String
    let locationLon : String
    let maxJoinNumber : String
    let description : String
    var dayName : String! = "Monday"
    var month : String! = "1"
    var time : String! = ""
    var day : String! = ""
    var year : String! = ""
    var participants = [String]()
    var requesters : Dictionary<String, AnyObject>? = nil
    var creator : User? = nil
    var address : String? = nil
    var fullDate : Date? = nil
    var isPast : Bool = false
    
    init(snapshot: FIRDataSnapshot) {
        let data = snapshot.value as! Dictionary<String, AnyObject>
        
        self.id = data["id"] as! String
        self.creatorID = data["creatorID"] as! String
        self.name = data["name"] as! String
        self.branch = data["branch"] as! String
        self.level = data["level"] as! String
        self.location = data["location"] as! String
        self.locationLat = data["locationLat"] as! String
        self.locationLon = data["locationLon"] as! String
        self.maxJoinNumber = data["maxJoinNumber"] as! String
        self.description = data["description"] as! String
        self.time = data["time"] as! String
        
        if let addrss = data["address"] as? String {
            self.address = addrss
        }
        
        if let prtcpnts = data["participants"] as? Dictionary<String, AnyObject> {
            self.participants = Array(prtcpnts.keys)
        }
        
        if let rqstrs = data["requested"] as? Dictionary<String, AnyObject> {
            self.requesters = rqstrs
        }
        
        if let date = data["fullDate"] as? String {
            let dateFormatter = DateFormatter()
            
            let newDate = date + " " + self.time
            
            dateFormatter.dateFormat = "dd.M.yyyy HH:mm"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            self.fullDate = dateFormatter.date(from: newDate)
            
            dateFormatter.dateFormat = "dd"
            self.day = dateFormatter.string(from: self.fullDate!)
            
            dateFormatter.dateFormat = "M"
            self.month = dateFormatter.string(from: self.fullDate!)
            
            dateFormatter.dateFormat = "yyyy"
            self.year = dateFormatter.string(from: self.fullDate!)
            
            dateFormatter.dateFormat = "EEEE"
            self.dayName = dateFormatter.string(from: self.fullDate!)
            
            if (self.fullDate?.isLessThanDate(dateToCompare: Date()))! {
                self.isPast = true
            }
        }
        
        REF_USERS.child(creatorID).observeSingleEvent(of: .value, with: { snapshot2 in
            if snapshot2.exists() {
                self.creator = User(snapshot: snapshot2)
            }
        })
        
    }
}
