//
//  ReportViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 8.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase

enum Reporting { case user, event, comment }

class ReportViewController: UIViewController {
    
    @IBOutlet var reportTextView: UITextView!

    var reporting : Reporting = .event
    var reported : AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -IBActions
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        switch reporting {
        case .user:
            
            break
        case .event:
            let event = reported as! Event
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "dd.M.yy, HH:mm"
            let date = dateFormatter.string(from: Date())
            
            let report = [
                "date": date,
                "report": reportTextView.text as String,
                "reporterID": (FIRAuth.auth()?.currentUser?.uid)!,
                "reportedID": event.creatorID
            ]
            
            REF_FEEDBACKS.child("events").child(event.id).child((FIRAuth.auth()?.currentUser?.uid)!).setValue(report)
            
            break
        case .comment:
            break
        }
    }
}
