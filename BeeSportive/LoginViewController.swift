//
//  LoginViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 15.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Async
import VideoSplashKit
import FTIndicator

class LoginViewController: VideoSplashViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var sloganLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var continueWithoutLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Facebook login button created
        let loginButton = FBSDKLoginButton()
        loginButton.alpha = 0.0
        self.view.addSubview(loginButton)
        loginButton.center = CGPoint(x: UIScreen.mainScreen().bounds.maxX/2.0, y: UIScreen.mainScreen().bounds.maxY-150)
        loginButton.readPermissions = ["email", "public_profile", "user_friends"]
        loginButton.delegate = self
        
        //Video Splash set and after animations
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("LoginVideo", ofType: "mp4")!)
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = false
        self.sound = true
        self.startTime = 0.0
        self.duration = 6.0
        self.alpha = 0.7
        self.backgroundColor = UIColor.whiteColor()
        self.contentURL = url
        self.restartForeground = false
        
        Async.main(after: 3, block: {
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.alpha = 0.0
                }, completion: { _ in
                    UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.logoImageView.alpha = 1.0
                        loginButton.alpha = 1.0
                        self.backgroundImage.alpha = 0.2
                        self.sloganLabel.alpha = 1.0
                        self.continueWithoutLoginButton.alpha = 1.0
                        }, completion: nil)
            })
        })
    }
    
    //
    // Facebook Delegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            print("Process error")
            // Process error
        }
        else if result.isCancelled {
            print("Login cancelled")
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("user_friends") && result.grantedPermissions.contains("public_profile")
            {   
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    guard user != nil else {
                        print(error)
                        // Toast
                        
                        return
                    }
                    FTIndicator.showNotificationWithImage(UIImage(named: "Success"), title: "Yay!", message: "You logged in succesfully!")
                    
                    let userRef = REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!)
                    
                    // Check if user already signed in before
                    // If not, create user object into database/users
                    userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if !snapshot.exists() {
                            let newUser : [String : AnyObject] = [
                                "displayName" : (user?.displayName)!,
                                "email" : (user?.email)!,
                                "photoURL" : (user?.photoURL?.absoluteString)!,
                                "id" : (user?.uid)!,
                                "friends" : [NSUUID().UUIDString : "zwj9ZfAdM7hPq04oEd8Yza99qPZ2" // Efe Helvacı's UID
                                ]
                            ]
                    
                            userRef.setValue(newUser)
                        }
                    })
                    
                    Async.main{
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
            else
            {
                // TODO
                // Not all permissions are granted
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
            FTIndicator.showNotificationWithImage(UIImage(named: "Success"), title: "You logged off!", message: "You logged off successfully")
            print("User signed out")
        } catch {
            FTIndicator.showNotificationWithImage(UIImage(named: "Error"), title: "Error!", message: "Problem occured while logging out")
            print("Couldn't sign out")
        }
    }
    
    //
    // Self created methods
    @IBAction func continueWithoutLoginButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
