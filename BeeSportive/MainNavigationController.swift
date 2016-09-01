//
//  MainNavigationController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 29.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import FirebaseDatabase
import FTIndicator

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    internal func pushProfilePage(userID: String) {
        
    }
    
   
    
    func getUserFromID(userID: String){
        
    }
}

extension MainNavigationController: SJSegmentedViewControllerDelegate {
    
    
}
