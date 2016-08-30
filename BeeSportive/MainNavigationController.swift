//
//  MainNavigationController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 29.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    internal var whoSendIt = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "navToProfileSegue" {
            let destinationViewController = segue.destinationViewController as! ProfileViewController
            
            destinationViewController.whoReachedMe = self.whoSendIt
        }
    }

}
