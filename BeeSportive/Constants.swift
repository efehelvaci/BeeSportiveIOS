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