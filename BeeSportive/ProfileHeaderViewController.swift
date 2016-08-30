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
    
    internal var delegate : AnyObject?
    
    let user = (FIRAuth.auth()?.currentUser)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHeader()
    }
    
    func setHeader() {
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage.layer.cornerRadius = self.profileImage.frame.width/2.0
        profileImage.clipsToBounds = true
    
        Async.background{
            Alamofire.request(.GET, (self.user.photoURL)!).responseData{ response in
                if let image = response.result.value {
                    self.profileImage.image = UIImage(data: image)
                    self.profileName.text = (self.user.displayName)!
                }
            }
        }
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        print("Back button clicked")
        if delegate != nil {
            delegate?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func profilEditButtonClicked(sender: AnyObject) {
        
    }
}
