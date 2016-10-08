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

class CommentViewController: UIViewController {

    @IBOutlet var commentTextView: UITextView!
    
    var senderVC : ProfileViewController?
    var user : User?
    var comment = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.text = comment
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        }
        
        let comment = [
            "id" : (FIRAuth.auth()?.currentUser?.uid)!,
            "date" : date,
            "comment" : commentText
        ]
        
        REF_USERS.child(user!.id).child("comments").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(comment)
        
        self.dismiss(animated: true, completion: {
            self.senderVC?.getComments()
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
