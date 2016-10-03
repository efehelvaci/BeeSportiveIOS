//
//  User.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 25.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//
import Foundation
import Firebase

class User {
    
    // MARK: Properties
    let displayName: String
    var photoURL: String?
    let email: String
    let id: String
    var followers = [String]()
    var following = [String]()
    var favoriteSports = [String]()
    var verified = false
    
    // MARK: Init
    init(snapshot: FIRDataSnapshot) {
        let data = snapshot.value as! Dictionary<String, AnyObject>
        
        self.displayName = data["displayName"] as! String
        self.photoURL = data["photoURL"] as? String
        self.email = data["email"] as! String
        self.id = data["id"] as! String
        
        if let followers = (data["followers"] as? Dictionary<String, AnyObject>)?.keys {
            self.followers = Array(followers)
        }
        
        if let following = (data["following"] as? Dictionary<String, AnyObject>)?.keys {
            self.following = Array(following)
        }
        
        if let favoriteSports = (data["favoriteSports"] as? Dictionary<String, String>)?.values {
            self.favoriteSports = Array(favoriteSports)
        }
        
        if let adminOptions = data["adminOptions"] as? Dictionary<String, AnyObject> {
            if let verify = adminOptions["verified"] as? Bool {
                self.verified = verify
            }
        }
    }
}
