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

    let backButton = UIBarButtonItem()
    let uid = FIRAuth.auth()!.currentUser!.uid
    
    var counter = 0
    var channels = [Channel]()
    var tempChannels = [Channel]()
    var filteredChannels = [Channel]()
    var isSearching = false
    var selectedChannelID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        REF_USERS.child(self.uid).child("joinedEvents").observe(.value, with: { snapshot in
            self.retrieveChannels()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        let tabBarCont = tabBarController as! TabBarController
        tabBarCont.menuButton.isHidden = true
        tabBarCont.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        let tabBarCont = tabBarController as! TabBarController
        tabBarCont.menuButton.isHidden = false
        tabBarCont.tabBar.isHidden = false
        
    }
    
    // MARK: - Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return filteredChannels.count
        } else {
            return channels.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell") as? ChannelCell {
            if isSearching {
                cell.configureCell(filteredChannels[(indexPath as NSIndexPath).row])
            } else {
                cell.configureCell(channels[(indexPath as NSIndexPath).row])
            }
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearching {
            self.selectedChannelID = filteredChannels[(indexPath as NSIndexPath).row].id
        } else {
            self.selectedChannelID = channels[(indexPath as NSIndexPath).row].id
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ChannelCell else { return }
        performSegue(withIdentifier: "toChatSegue", sender: cell)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toChatSegue" {
            if let destVC = segue.destination as? ChatVC {
                destVC.channelID = self.selectedChannelID
                guard let cell = sender as? ChannelCell else { return }
                destVC.navigationItem.title = cell.title.text
            }
        }
        
    }
    
    // MARK: - Search Bar Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            let key = searchBar.text!.capitalized
            filteredChannels = channels.filter({$0.title.range(of: key) != nil})
        }
        tableView.reloadData()
    }
    
    func retrieveChannels () {
        REF_USERS.child(uid).child("eventsCreated").observe(.value, with: { snapshot in
            var snaps = [FIRDataSnapshot]()
            
            if snapshot.exists() {
                snaps = snapshot.children.allObjects as! [FIRDataSnapshot]
            }
            
            REF_USERS.child(self.uid).child("joinedEvents").observeSingleEvent(of: .value, with: { snapshot2 in
                self.tempChannels.removeAll()
                
                if snapshot2.exists(){
                    for snap in snapshot2.children {
                        snaps.append(snap as! FIRDataSnapshot)
                    }
                }
                
                self.counter = 0
                for snap in snaps {
                    let channelID = snap.value as! String
                    
                    REF_CHANNELS.child(channelID).observe(.value, with: { (snap) in
                        if snap.exists() {
                            if self.channels.count != Int(snaps.count) {
                                let channel = Channel(snapshot: snap)
                                self.tempChannels.append(channel)
                            }
                        }
                        self.counter += 1
                        
                        if self.counter == snaps.count {
                            self.channels = self.tempChannels.sorted(by: {($0.date.isGreaterThanDate(dateToCompare: $1.date))})
                            self.tableView.reloadData()
                        }
                    })

                }
            })
        })
    }
    
}
