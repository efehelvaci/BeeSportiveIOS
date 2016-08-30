//
//  Constants.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 30/08/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Firebase

let REF_DATA = FIRDatabase.database().reference()
let REF_CHANNELS = REF_DATA.child("channels")
let REF_USERS = REF_DATA.child("users")
let REF_EVENTS = REF_DATA.child("events")

let branchs = ["Badminton", "Baseball", "Basketball", "Billard", "Bowling", "Crossfit", "Curling", "Cycling", "Dancing", "Diving", "Fencing", "Fitness", "Football", "Golf", "Gymnastic", "Handball", "Ice Hockey", "Ice Skating", "Martial Arts", "Motor Sports", "Mountain Climbing", "Orienting", "Paintball", "Parkour", "Pilates", "Pokemon Go", "Quidditch", "Rafting", "Rowing", "Rugby", "Running", "Sailing", "Skateboarding", "Skating", "Snowboarding", "Surfing", "Swimming", "Table Tennis", "Tennis", "Triathlon", "Volleyball", "Water Polo", "Wind Surfing", "Wrestling", "Yoga", "Zumba"]
let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]