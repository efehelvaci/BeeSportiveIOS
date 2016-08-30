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
import REFrostedViewController

class ProfileHeaderViewController: UIViewController {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var profileName: UILabel!
    @IBOutlet var editButton: UIButton!
    
    internal var delegate : AnyObject?
    internal var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user!.id != FIRAuth.auth()?.currentUser?.uid {
            editButton.removeFromSuperview()
        }
        
        setHeader()
    }
    
    //
    // Self created methods
    func setHeader() {
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage.layer.cornerRadius = self.profileImage.frame.width/2.0
        profileImage.clipsToBounds = true
    
        Alamofire.request(.GET, (self.user!.photoURL)!).responseData{ response in
            if let image = response.result.value {
                self.profileImage.image = UIImage(data: image)
                self.profileName.text = self.user!.displayName
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
        
    }
}
