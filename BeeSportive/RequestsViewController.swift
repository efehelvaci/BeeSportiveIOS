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

class RequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    let reuseIdentifier = "RequestCell"
    
    var profileVC : ProfileViewController!
    var senderVC : EventDetailViewController? = nil
    var eventID : String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileVC = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? RequestsTableViewCell {
            
            cell.requesterID = users[(indexPath as NSIndexPath).row].id
            cell.eventID = eventID!
            cell.userNameLabel.text = users[(indexPath as NSIndexPath).row].displayName
            cell.delegate = self
            
            cell.userImage.kf.setImage(with: URL(string: self.users[(indexPath as NSIndexPath).row].photoURL!))
            
            return cell
        } else { return UITableViewCell() }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileVC.getUser(userID: users[indexPath.row].id)
        show(profileVC, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
