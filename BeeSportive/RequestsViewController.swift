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

class RequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    let reuseIdentifier = "RequestCell"
    
    var senderVC : EventDetailViewController? = nil
    var eventID : String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            viewController5.user = self.users[indexPath.row]
        })
    }
}
