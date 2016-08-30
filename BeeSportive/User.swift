//
//  User.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 25.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//
import Foundation

class User {
    // MARK: Properties
    let displayName: String
    var photoURL: String?
    let email: String
    let id: String
    
    // MARK: Init
    init(displayName: String, photoURL: String, email: String, id: String) {
        self.displayName = displayName
        self.photoURL = photoURL
        self.email = email
        self.id = id
    }
}