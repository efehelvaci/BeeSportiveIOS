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
    var channels = [Channel]()
    var selectedChannelID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        REF_USERS.child(uid).child("eventsCreated").observeEventType(.Value, withBlock: { snapshot in
            self.channels.removeAll()
            for snap in snapshot.children {
                guard let data = snap as? FIRDataSnapshot else { return }
                let channelID = data.value as! String
                REF_CHANNELS.child(channelID).observeEventType(.Value, withBlock: { (snap) in
                    if self.channels.count != Int(snapshot.childrenCount) {
                        let channel = Channel(snapshot: snap)
                        self.channels.append(channel)
                        self.tableView.reloadData()
                    }
                })
            }
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell") as? ChannelCell {
            cell.configureCell(channels[indexPath.row])
            return cell
        } else { return UITableViewCell() }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedChannelID = channels[indexPath.row].id
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChannelCell else { return }
        performSegueWithIdentifier("toChatSegue", sender: cell)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChatSegue" {
            if let destVC = segue.destinationViewController as? ChatVC {
                destVC.channelID = self.selectedChannelID
                guard let cell = sender as? ChannelCell else { return }
                destVC.navigationItem.title = cell.title.text
            }
        }
    }

}