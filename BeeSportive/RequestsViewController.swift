//
//  RequestsViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 1.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Async
import Firebase
import Haneke

class RequestsViewController: UIViewController, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    let reuseIdentifier = "RequestCell"
    var eventID : String?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? RequestsTableViewCell {
            
            cell.requesterID = users[indexPath.row].id
            cell.eventID = eventID!
            cell.userNameLabel.text = users[indexPath.row].displayName
            cell.delegate = self
            cell.userImage.hnk_setImageFromURL(NSURL(string: self.users[indexPath.row].photoURL!)!, placeholder: UIImage(), format: nil, failure: nil, success: { image in
                cell.userImage.image = image
            })
            
            return cell
        } else { return UITableViewCell() }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewController5 = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        self.presentViewController(viewController5, animated: true, completion: { _ in
            viewController5.getUser(self.users[indexPath.row].id)
        })
    }
    
    func getUsers() {
        REF_EVENTS.child(eventID!).child("requested").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                
                self.users.removeAll()

                let requesterIDs = Array((snapshot.value as! [String : AnyObject]).values)
                
                for element in requesterIDs {
                    let id = element.valueForKey("id") as! String
                    let result = element.valueForKey("result") as! String
                    
                    if result == "requested" { self.getUser(id) }
                }
            }
        })
    }
    
    func getUser(userID : String) {
        REF_USERS.child(userID).observeEventType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                
                let dict = snapshot.value as! Dictionary<String, AnyObject>
                
                let displayName = dict["displayName"] as! String
                let email = dict["email"] as! String
                let photoURL = dict["photoURL"] as! String
                let id = dict["id"] as! String
                
                let user = User(displayName: displayName, photoURL: photoURL, email: email, id: id)
                
                self.users.insert(user, atIndex: 0)
                
                Async.main{
                    self.tableView.reloadData()
                }
            }
        })
    }
}
