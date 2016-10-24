//
//  NotificationsViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 5.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Async

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var tempNotifications = [Notification]()
        
        REF_NOTIFICATIONS.child(FIRAuth.auth()!.currentUser!.uid).observe(.value, with: { snapshot in
            if snapshot.exists() {
                
                tempNotifications.removeAll()
                
                for snap in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    let notification = Notification(snapshot: snap)
                    
                    var contains = false
                    for element in tempNotifications {
                        if element.notification == notification.notification{
                            contains = true
                        }
                    }
                    
                    if !contains{
                        tempNotifications.insert(notification, at: 0)
                    }
                }
                
                self.notifications = tempNotifications
                
                if self.isViewLoaded {
                    self.tableView.reloadData()

                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        if indexPath.row < notifications.count {
            cell.configureCell(notification: notifications[indexPath.row])
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Async.main(after: 0.25, {
            tableView.deselectRow(at: indexPath, animated: true)
        })

        if indexPath.row >= notifications.count {return}
        
        switch notifications[indexPath.row].notificationType {
        case .joinRequestAccepted,
             .incomingJoinRequest:
            
            // Go to event's page
            if notifications[indexPath.row].notificationConnection != "" {
                REF_EVENTS.child(notifications[indexPath.row].notificationConnection).observeSingleEvent(of: .value, with: {snapshot in
                    if snapshot.exists(){
                        let event = Event(snapshot: snapshot)
                        
                        let eventDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
                        eventDetailVC.event = event
                        self.present(eventDetailVC, animated: true, completion: nil)
                    }
                })
            }
            break
        case .newFollower:
            
            // Go to followers profile page
            if notifications[indexPath.row].notificationConnection != "" {
                let usersProfileVC = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                usersProfileVC.getUser(userID: notifications[indexPath.row].notificationConnection)
                present(usersProfileVC, animated: true, completion: nil)
            }
            
            break
        case .general:
            
            // Open link in default browser
            if let checkURL = URL(string: notifications[indexPath.row].notificationConnection) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(checkURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(checkURL)
                }
            }
            break
        default:
            break
        }
    }
}
