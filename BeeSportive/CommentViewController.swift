//
//  CommentViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 8.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import FTIndicator

class CommentViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var characterCounter: UILabel!
    
    var senderVC : ProfileViewController?
    var user : User?
    var comment = ""
    let characterLimit = 300
    var leftCharacterLimit = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        commentTextView.text = comment
        leftCharacterLimit = characterLimit - comment.characters.count
        
        characterCounter.text = "\(leftCharacterLimit)"
    }
    
    // MARK: -IBActions
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
    
        dateFormatter.dateFormat = "dd.M.yy, HH:mm"
        let date = dateFormatter.string(from: Date())
        
        let commentText = commentTextView.text!
        commentTextView.text = ""
        
        if commentText.characters.count < 1 {
            FTIndicator.showInfo(withMessage: "Comment can't be blank!")
            return
        } else if commentText.characters.count > 300 {
            FTIndicator.showInfo(withMessage: "Comment too long! (Max. 300 characters)")
            return
        }
        
        let comment = [
            "id" : (FIRAuth.auth()?.currentUser?.uid)!,
            "date" : date,
            "comment" : commentText
        ]
        
        REF_USERS.child(user!.id).child("comments").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(comment)
        
        let notifier = [
            "notification": (currentUser.instance.user?.displayName)! + " commented on your profile!" ,
            "notificationConnection": (FIRAuth.auth()?.currentUser?.uid)!,
            "type": "newComment"
        ]
        
        REF_NEW_NOTIFICATIONS.child(user!.id).setValue(true)
        REF_NOTIFICATIONS.child(user!.id).childByAutoId().setValue(notifier)
        
        self.dismiss(animated: true, completion: {
            self.senderVC?.getComments()
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        leftCharacterLimit = characterLimit - commentTextView.text.characters.count
        characterCounter.text = "\(leftCharacterLimit)"
        
        if leftCharacterLimit < 0 {
            characterCounter.textColor = UIColor.red
        } else {
            characterCounter.textColor = UIColor.gray
        }
    }
    
}
