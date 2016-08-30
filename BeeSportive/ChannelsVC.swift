//
//  ChannelsVC.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 30/08/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase

class ChannelsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let uid = FIRAuth.auth()!.currentUser!.uid
    var channelIDs = [String]()
    var channelID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        REF_USERS.child(uid).child("eventsCreated").observeEventType(.Value, withBlock: { snapshot in
            self.channelIDs.removeAll()
            for snap in snapshot.children {
                if let data = snap as? FIRDataSnapshot {
                    self.channelIDs.append(String(data.value!))
                    self.tableView.reloadData()
                }
            }
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelIDs.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell") as? ChannelCell {
            cell.configureCell(channelIDs[indexPath.row])
            return cell
        } else { return UITableViewCell() }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        channelID = channelIDs[indexPath.row]
        performSegueWithIdentifier("toChatSegue", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChatSegue" {
            if let destVC = segue.destinationViewController as? ChatVC {
                destVC.channelID = self.channelID
            }
        }
    }

}