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
    
    fileprivate init() {
        users = [User]()
        
        REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("following").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let payload = Array((snapshot.value as! Dictionary<String, AnyObject>).values)
                var usrs = [User]()
                
                for element in payload {
                    let id = element["id"] as! String
                    
                    REF_USERS.child(id).observeSingleEvent(of: .value, with: {snapshot2 in
                        if snapshot2.exists() {
                            usrs.insert(User(snapshot: snapshot2), at: 0)
                            
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

    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func dateFromString(_ dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        if let str = dateFormatter.date(from: dateStr) { return str }
        else { return Date() }
    }

    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

extension String {
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
