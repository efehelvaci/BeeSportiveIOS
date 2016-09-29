//
//  Functions.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 1.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation
import Firebase

protocol observeFollowing {
    func followingsChanged()
}

// TODO: -Get user info first, use all over the app

class followingUsers {
    
    //MARK: Shared Instance
    
    static let instance = followingUsers()
    
    //MARK: Local Variable
    
    var delegate : observeFollowing?
    var users : [User] {
        didSet{
            delegate?.followingsChanged()
        }
    }
    
    //MARK: Init
    
    private init() {
        users = [User]()
        
        REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                let payload = Array((snapshot.value as! Dictionary<String, AnyObject>).values)
                var usrs = [User]()
                
                for element in payload {
                    let id = element["id"] as! String
                    
                    REF_USERS.child(id).observeSingleEventOfType(.Value, withBlock: {snapshot2 in
                        if snapshot2.exists() {
                            usrs.insert(User(snapshot: snapshot2), atIndex: 0)
                            
                            if ((payload.last)!).isEqual(element) {self.users = usrs}
                        }
                    })
                }
            }
        })
    }
}

extension UIViewController {

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func dismissKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func dateFromString(dateStr: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        if let str = dateFormatter.dateFromString(dateStr) { return str }
        else { return NSDate() }
    }

    func dateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
