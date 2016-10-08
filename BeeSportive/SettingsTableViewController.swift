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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
