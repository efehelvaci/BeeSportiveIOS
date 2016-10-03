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
import AlamofireImage

class RequestsViewController: UIViewController, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    let reuseIdentifier = "RequestCell"
    var eventID : String?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    private func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? RequestsTableViewCell {
            
            cell.requesterID = users[(indexPath as NSIndexPath).row].id
            cell.eventID = eventID!
            cell.userNameLabel.text = users[(indexPath as NSIndexPath).row].displayName
            cell.delegate = self
            
            Alamofire.request(self.users[(indexPath as NSIndexPath).row].photoURL!).responseImage(completionHandler: { response in
                if let image = response.result.value {
                    cell.userImage.image = image
                }
            })
            
            return cell
        } else { return UITableViewCell() }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.present(viewController5, animated: true, completion: { _ in
            viewController5.getUser(userID: self.users[(indexPath as NSIndexPath).row].id)
        })
    }
    
    func getUsers() {
        REF_EVENTS.child(eventID!).child("requested").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                
                self.users.removeAll()

                let requesterIDs = Array((snapshot.value as! [String : AnyObject]).values)
                
                for element in requesterIDs {
                    let id = element.value(forKey: "id") as! String
                    let result = element.value(forKey: "result") as! String
                    
                    if result == "requested" { self.getUser(id) }
                }
            }
        })
    }
    
    func getUser(_ userID : String) {
        REF_USERS.child(userID).observe(.value, with: { snapshot in
            if snapshot.exists() {
                
                let dict = snapshot.value as! Dictionary<String, AnyObject>
                
                let displayName = dict["displayName"] as! String
                let email = dict["email"] as! String
                let photoURL = dict["photoURL"] as! String
                let id = dict["id"] as! String
                
                let user = User(displayName: displayName, photoURL: photoURL, email: email, id: id)
                
                self.users.insert(user, at: 0)
                
                Async.main{
                    self.tableView.reloadData()
                }
            }
        })
    }
}
