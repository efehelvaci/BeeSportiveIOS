//
//  ReportViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 8.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import FTIndicator

enum Reporting { case user, event, comment }

class ReportViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var reportTextView: UITextView!
    @IBOutlet var characterCounter: UILabel!
    
    var reporting : Reporting = .event
    var reported : AnyObject?
    let characterLimit = 300
    var leftCharacterLimit = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportTextView.delegate = self
    }
    
    // MARK: -IBActions
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        if reportTextView.text.characters.count == 0 {
            FTIndicator.showInfo(withMessage: "Report can't be blank!")
            return
        } else if reportTextView.text.characters.count > 300 {
            FTIndicator.showInfo(withMessage: "Report too long! (Max. 300 characters)")
            return
        }
        
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
        
        dismiss(animated: true, completion: {
            self.reportTextView.text = ""
            self.characterCounter.text = "\(self.characterLimit)"
            FTIndicator.showToastMessage("Report sent! Thanks for your concern!")
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        leftCharacterLimit = characterLimit - reportTextView.text.characters.count
        characterCounter.text = "\(leftCharacterLimit)"
        
        if leftCharacterLimit < 0 {
            characterCounter.textColor = UIColor.red
        } else {
            characterCounter.textColor = UIColor.gray
        }
    }
}
