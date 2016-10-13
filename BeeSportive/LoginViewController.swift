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
import FTIndicator

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var sloganLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Facebook login button create
        let loginButton = FBSDKLoginButton()
        loginButton.alpha = 0.0
        self.view.addSubview(loginButton)
        loginButton.center = CGPoint(x: UIScreen.main.bounds.maxX/2.0, y: UIScreen.main.bounds.maxY-150)
        loginButton.readPermissions = ["email", "public_profile", "user_friends"]
        loginButton.delegate = self
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.logoImageView.alpha = 1.0
            loginButton.alpha = 1.0
            self.backgroundImage.alpha = 0.2
            self.sloganLabel.alpha = 1.0
            }, completion: nil)
    }
    
    // MARK: -Facebook Delegate Methods
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User Logged In")
        
        if (error != nil)
        {
            print(error)
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
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    guard user != nil else {
                        print(error)
                        // Toast
                        
                        return
                    }
                    FTIndicator.showNotification(with: UIImage(named: "Success"), title: "Yay!", message: "You logged in succesfully!")
                    
                    // Check if user already signed in before
                    // If not, create user object into database/users
                    REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
                        if !snapshot.exists() {
                            let newUser : [String : AnyObject] = [
                                "displayName" : (user?.displayName)! as AnyObject,
                                "email" : (user?.email)! as AnyObject,
                                "photoURL" : (user?.photoURL?.absoluteString)! as AnyObject,
                                "id" : (user?.uid)! as AnyObject
                                ]
                    
                            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).setValue(newUser)
                            
                            
                            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
                                if snapshot.exists() {
                                    currentUser.instance.user = User(snapshot: snapshot)
                                }
                            })
                        }
                    })
                    
                    Async.main{
                        let tabCon = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
                        
                        self.appDelegate.window?.rootViewController = tabCon
                        
                        tabCon?.view.alpha = 0
                        
                        UIView.animate(withDuration: 1, animations: {
                            tabCon?.view.alpha = 1
                        })
                    }
                }
            }
            else
            {
                // TODO: - Not all permissions are granted
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
            FTIndicator.showNotification(with: UIImage(named: "Success"), title: "You logged off!", message: "You logged off successfully")
            print("User signed out")
        } catch {
            FTIndicator.showNotification(with: UIImage(named: "Error"), title: "Error!", message: "Problem occured while logging out")
            print("Couldn't sign out")
        }
    }
}
