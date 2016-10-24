//
//  Notification.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 24.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation
import Firebase

enum NotificationType {
    case joinRequestAccepted
    case newFollower
    case general
    case incomingJoinRequest
    case notValid
}

class Notification {
    var notificationType : NotificationType = .notValid
    var notification = ""
    var notificationConnection = ""
    
    init(snapshot: FIRDataSnapshot){
        let data = snapshot.value as! Dictionary<String, AnyObject>
        
        if let notification = data["notification"] as? String {
            self.notification = notification
        }
        
        if let notificationType = data["type"] as? String {
            switch notificationType {
            case "joinRequestAccepted":
                self.notificationType = NotificationType.joinRequestAccepted
                break
            case "newFollower":
                self.notificationType = NotificationType.newFollower
                break
            case "general":
                self.notificationType = NotificationType.general
                break
            case "incomingJoinRequest":
                self.notificationType = NotificationType.incomingJoinRequest
                break
            default:
                self.notificationType = NotificationType.notValid
                break
            }
        }
        
        if let notificationConnection = data["notificationConnection"] as? String {
            self.notificationConnection = notificationConnection
        }
    }
}
