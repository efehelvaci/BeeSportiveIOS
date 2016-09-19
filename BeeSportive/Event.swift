//
//  Event.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 16.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation

class Event {
    let id : String
    let creatorID : String
    let creatorImageURL : String
    let creatorName : String
    let name : String
    let branch : String
    let level : String
    let location : String
    let locationLat : String
    let locationLon : String
    let maxJoinNumber : String
    let description : String
    let month : String
    let time : String
    let day : String
    let year : String
    
    init(creatorID: String, creatorImageURL: String, creatorName: String, name: String, branch: String, level: String, location: String, locationLat: String, locationLon : String, maxJoinNumber: String, description : String, time: String, month: String, day: String, year: String, id: String){
        self.creatorID = creatorID
        self.creatorImageURL = creatorImageURL
        self.creatorName = creatorName
        self.name = name
        self.branch = branch
        self.level = level
        self.location = location
        self.locationLat = locationLat
        self.locationLon = locationLon
        self.maxJoinNumber = maxJoinNumber
        self.description = description
        self.time = time
        self.day = day
        self.month = month
        self.year = year
        self.id = id
    }
}