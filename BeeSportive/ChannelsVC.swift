//
//  ChannelsVC.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 30/08/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase

class ChannelsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    let uid = FIRAuth.auth()!.currentUser!.uid
    var channels = [Channel]()
    var filteredChannels = [Channel]()
    var isSearching = false
    var selectedChannelID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        REF_USERS.child(uid).child("eventsCreated").observeEventType(.Value, withBlock: { snapshot in
            self.channels.removeAll()
            self.channels.removeAll()
            for snap in snapshot.children {
                guard let data = snap as? FIRDataSnapshot else { return }
                let channelID = data.value as! String
                REF_CHANNELS.child(channelID).observeEventType(.ChildChanged, withBlock: { (snapshot) in
                    self.viewDidLoad()
                })
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tabBarCont = tabBarController as! TabBarController
        tabBarCont.menuButton.hidden = true
        tabBarCont.tabBar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let tabBarCont = tabBarController as! TabBarController
        tabBarCont.menuButton.hidden = false
        tabBarCont.tabBar.hidden = false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching { return filteredChannels.count }
        else { return channels.count }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ChannelCell") as? ChannelCell {
            if isSearching { cell.configureCell(filteredChannels[indexPath.row]) }
            else { cell.configureCell(channels[indexPath.row]) }
            return cell
        } else { return UITableViewCell() }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isSearching { self.selectedChannelID = filteredChannels[indexPath.row].id }
        else { self.selectedChannelID = channels[indexPath.row].id }
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

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            let key = searchBar.text!.capitalizedString
            filteredChannels = channels.filter({$0.title.rangeOfString(key) != nil})
        }; tableView.reloadData()
    }

}