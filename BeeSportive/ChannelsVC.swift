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

    override func viewDidLoad() {
        super.viewDidLoad()
//        REF_CHANNELS.observeEventType(.Value, withBlock: { snapshot in
//            self.channels.removeAll()
//            for snap in snapshot.children {
//                if let data = snap as? FIRDataSnapshot {
//                    self.channels.append(Channel(snapshot: data))
//                    self.tableView.reloadData()
//                }
//            }
//        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell") as? ChannelCell {
//            cell.configureCell(channels[indexPath.row])
            return cell
        } else { return UITableViewCell() }
    }

}