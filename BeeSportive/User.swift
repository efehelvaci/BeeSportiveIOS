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
    var displayName: String! = ""
    var photoURL: String! = "https://firebasestorage.googleapis.com/v0/b/beesportive-cbd41.appspot.com/o/picture-95970-1460131169.png?alt=media&token=f4837663-6add-4039-be16-eab5a915a5cc"
    var id: String!
    var bio: String = "Sportive! \u{1F41D}"
    var followers = [String]()   // Follower users ID's
    var following = [String]()   // Following users ID's
    var favoriteSports = [String]()
    var verified = false   // Is user verified
    
    // MARK: Init
    init(snapshot: FIRDataSnapshot) {
        let data = snapshot.value as! Dictionary<String, AnyObject>
        
        self.id = data["id"] as! String
        
        if let displayName = data["displayName"] as? String {
            self.displayName = displayName
        }
        
        if let photoURL = data["photoURL"] as? String {
            self.photoURL = photoURL
        }
        
        if let followers = (data["followers"] as? Dictionary<String, AnyObject>)?.keys {
            self.followers = Array(followers)
        }
        
        if let following = (data["following"] as? Dictionary<String, AnyObject>)?.keys {
            self.following = Array(following)
        }
        
        if let favoriteSports = (data["favoriteSports"] as? Dictionary<String, String>)?.values {
            self.favoriteSports = Array(favoriteSports)
        }
        
        if let biography = data["bio"] as? String {
            self.bio = biography
        }
        
        if let adminOptions = data["adminOptions"] as? Dictionary<String, AnyObject> {
            if let verify = adminOptions["verified"] as? Bool {
                self.verified = verify
            }
        }
        
    }
}
