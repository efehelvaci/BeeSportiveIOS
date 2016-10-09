//
//  BioViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 9.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FTIndicator
import Firebase

class BioViewController: UIViewController {
    
    @IBOutlet var bioTextView: UITextView!
    
    var senderVC: ProfileViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
    }
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        if var bio = bioTextView.text {
            if bio.characters.count > 100 {
                FTIndicator.showInfo(withMessage: "Bio cannot be longer than 100 characters!")
                return
            }
            if bio.characters.count < 1 {
                bio = ""
            }
            
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("bio").setValue(bio)
            
            let user = senderVC?.user
            user?.bio = bio
            senderVC?.user = user
            
            dismiss(animated: true, completion: { _ in
                self.senderVC?.setUser()
            })
        }
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
