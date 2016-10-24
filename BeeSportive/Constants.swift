//
//  Constants.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 30/08/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Firebase
import UIKit

let screenSize = UIScreen.main.bounds.size

let REF_DATA = FIRDatabase.database().reference()
let REF_NOTIFICATIONS = REF_DATA.child("notifications")
let REF_CHANNELS = REF_DATA.child("channels")
let REF_USERS = REF_DATA.child("users")
let REF_EVENTS = REF_DATA.child("events")
let REF_POPULAR_EVENTS = REF_DATA.child("popularEvents")
let REF_FEEDBACKS = REF_DATA.child("feedbacks")
let REF_STORAGE = FIRStorage.storage().reference()

let branchs = ["Badminton", "Baseball", "Basketball", "Billard", "Bowling", "Canoe", "Crossfit", "Curling", "Cycling", "Dancing", "Diving", "Fencing", "Fitness", "Football", "Golf", "Gymnastic", "Handball", "Hiking", "Ice Hockey", "Ice Skating", "Martial Arts", "Motor Sports", "Mountain Climbing", "Orienting", "Paintball", "Parkour", "Pilates", "Pokemon Go", "Quidditch", "Rafting", "Rowing", "Rugby", "Running", "Sailing", "Skateboarding", "Skating", "Skiing", "Snowboarding", "Surfing", "Swimming", "Table Tennis", "Tennis", "Triathlon", "Volleyball", "Water polo", "Wind surfing", "Wrestling", "Yoga"]
let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
let levels = ["Amateur", "Starter", "Mid-level", "Hard", "Expert"]
