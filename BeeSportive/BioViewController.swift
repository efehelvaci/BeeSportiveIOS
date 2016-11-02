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

class BioViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var bioTextView: UITextView!
    @IBOutlet var characterCounter: UILabel!
    
    var senderVC: ProfileViewController?
    var oldBio = ""
    let characterLimit = 80
    var leftCharacterLimit = 80

    override func viewDidLoad() {
        bioTextView.delegate = self
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bioTextView.text = oldBio
        
        leftCharacterLimit = characterLimit - oldBio.characters.count
        characterCounter.text = "\(leftCharacterLimit)"
    }
    
    // MARK: -IBActions

    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        if var bio = bioTextView.text {
            if bio.characters.count > 80 {
                FTIndicator.showInfo(withMessage: "Bio cannot be longer than 80 characters!")
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
                FTIndicator.showToastMessage("You successfully changed your bio!")
            })
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        leftCharacterLimit = characterLimit - bioTextView.text.characters.count
        characterCounter.text = "\(leftCharacterLimit)"
        
        if leftCharacterLimit < 0 {
            characterCounter.textColor = UIColor.red
        } else {
            characterCounter.textColor = UIColor.gray
        }
    }
}
