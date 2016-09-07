//
//  ProfileHeaderViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 30.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Async
import Alamofire
import Firebase
import FTIndicator

class ProfileHeaderViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileName: UILabel!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var backButton: UIButton!
    let imagePicker = UIImagePickerController()
    
    var delegate : AnyObject?
    var user : User?
    var sender = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sender == 0 ? (backButton.hidden = true) : (backButton.hidden = false)
        
        user!.id != FIRAuth.auth()?.currentUser?.uid ? (editButton.hidden = true) : (editButton.hidden = false)
        
        if user?.displayName != profileName.text { setHeader() }
    }
    
    //
    // Self created methods
    func setHeader() {
        FTIndicator.showProgressWithmessage("Loading", userInteractionEnable: false)
        
        editButton.alpha = 0
        profileImage.alpha = 0
        profileName.alpha = 0
        
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage.layer.cornerRadius = self.profileImage.frame.width/2.0
        profileImage.clipsToBounds = true
    
        Alamofire.request(.GET, (self.user!.photoURL)!).responseData{ response in
            if let image = response.result.value {
                self.profileImage.image = UIImage(data: image)
                self.profileName.text = self.user!.displayName
                
                let colors = UIImage(data: image)?.getColors()
    
                self.backgroundView.backgroundColor = colors!.backgroundColor
                self.profileName.textColor = colors!.primaryColor
                
                UIView.animateWithDuration(1, animations: {
                    self.profileName.alpha = 1
                    self.profileImage.alpha = 1
                    self.editButton.alpha = 1
                    }, completion: { _ in
                        FTIndicator.dismissProgress()
                })
            }
        }
    }
    
    //
    // Button Actions
    @IBAction func backButtonClicked(sender: AnyObject) {
        if delegate != nil {
            delegate?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func profilEditButtonClicked(sender: AnyObject) {
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImage.image = image
        if let data = UIImageJPEGRepresentation(image, 0.2) {
            var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            path = path.stringByAppendingString("/\(user!.id).jpg")
            do { try data.writeToFile(path, options: .DataWritingAtomic) }
            catch { print(error) }
            let url = NSURL(fileURLWithPath: path)
            REF_STORAGE.child(user!.id).putFile(url, metadata: nil, completion: { (meta, error) in
                if let meta = meta {
                    let url = meta.downloadURL()!
                    self.user!.photoURL = url.absoluteString
                    REF_USERS.child(self.user!.id).child("photoURL").setValue(url.absoluteString)
                } else { print(error) }
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }

}
