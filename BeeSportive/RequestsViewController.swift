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
import Alamofire

class RequestsViewController: UIViewController, UITableViewDelegate{

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
            cell.userNameLabel.text = users[indexPath.row].displayName
            
            Alamofire.request(.GET, (self.users[indexPath.row].photoURL)!).responseData{ response in
                if let image = response.result.value {cell.userImage.image = UIImage(data: image)}
            }

            
            return cell
        } else { return UITableViewCell() }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func getUsers() {
        REF_EVENTS.child(eventID!).child("requested").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {

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
        REF_USERS.child(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                let dict = NSDictionary(dictionary: snapshot.value as! [String : AnyObject])
                
                let displayName = dict.valueForKey("displayName") as! String
                let email = dict.valueForKey("email") as! String
                let photoURL = dict.valueForKey("photoURL") as! String
                let id = dict.valueForKey("id") as! String
                
                let user = User(displayName: displayName, photoURL: photoURL, email: email, id: id)
                
                self.users.insert(user, atIndex: 0)
                
                Async.main{
                    self.tableView.reloadData()
                }
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
