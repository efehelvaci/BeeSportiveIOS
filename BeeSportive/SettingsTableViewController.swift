//
//  SettingsTableViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 7.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FBSDKShareKit
import SDCAlertView
import Firebase
import FTIndicator
import Async

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var cell1: UITableViewCell!
    
    @IBOutlet var cell2: UITableViewCell!
    
    @IBOutlet var cell3: UITableViewCell!

    let button : FBSDKShareButton = FBSDKShareButton()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var privacyAlert : AlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Beesportive share content
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://www.beesportive.com/")
        content.contentTitle = "BeeSportive"
        content.contentDescription = "Üniversite öğrencileri tarafından kurulan BeeSportive, günümüzün en büyük problemlerinden olan asosyalliğin, spor yapmak için olan motivasyon eksikliğinin ve hareketsizliğe bağlı sağlık problemlerinin önüne geçmek adına insanları spor yaparken bir araya getiren bir platformdur."
        content.imageURL = URL(string: "http://www.beesportive.com/wp-content/uploads/2016/07/rsz_logo_transparent.png")
        button.shareContent = content
        
        privacyAlert = AlertController(attributedTitle: NSAttributedString(string: "Privacy Policy", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17.0)]), attributedMessage: getPrivacyPolicy(), preferredStyle: .alert)
        privacyAlert.add(AlertAction(title: "Okay", style: .normal, handler: { _ in
                self.privacyAlert.dismiss()
            })
        )
    }

    // MARK: -Table View Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellClicked = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        switch cellClicked {
        case cell1:
            button.sendActions(for: UIControlEvents.touchUpInside)
            print("1")
            break
        case cell2:
            privacyAlert.present()
            print("2")
            break
        case cell3:
            print("3")
            do {
                try FIRAuth.auth()!.signOut()
                FTIndicator.showNotification(with: UIImage(named: "Success"), title: "You logged off!", message: "You logged off successfully")
                
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                Async.main{
                    let loginScreen = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    
                    self.appDelegate.window?.rootViewController = loginScreen
                    
                    loginScreen.view.alpha = 0
                    
                    UIView.animate(withDuration: 1, animations: {
                        loginScreen.view.alpha = 1
                    })
                }
                
            } catch {
                FTIndicator.showNotification(with: UIImage(named: "Error"), title: "Error!", message: "Problem occured while logging out")
                print("Couldn't sign out")
            }
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
