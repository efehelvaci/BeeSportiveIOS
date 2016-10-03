//
//  TabBarController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 6.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FirebaseAuth
import FTIndicator
import Async

class TabBarController: UITabBarController {
    
    let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 72))
    var eventCreationNavCon : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor(red: 249/255, green: 225/255, blue: 6/255, alpha: 1)

        let eventCreateVC = storyboard!.instantiateViewController(withIdentifier: "EventFormViewController")
        eventCreationNavCon = UINavigationController(rootViewController: eventCreateVC)
        eventCreateVC.navigationItem.title = "Create Event"
        
        let viewController1 = storyboard!.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        viewController1.tabBarItem = UITabBarItem(title: "Events", image: UIImage(named: "Events"), tag: 1)
        let nav1 = UINavigationController(rootViewController: viewController1)
        
        let viewController2 = storyboard!.instantiateViewController(withIdentifier: "UsersVC") as! UsersVC
        viewController2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "SearchPeople"), tag: 2)
        
        let viewController3 = UIViewController()
        viewController3.tabBarItem.isEnabled = false
        
        let viewController4 = UIViewController()
        viewController4.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(named: "Notifications"), tag: 4)
        
        let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        viewController5.getUser(userID: (FIRAuth.auth()?.currentUser?.uid)!)
        viewController5.sender = 0
        viewController5.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Avatar"), tag: 5)
        
        setupMiddleButton()
        
        self.viewControllers = [nav1, viewController2, viewController3, viewController4, viewController5]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMiddleButton() {
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height
        menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        self.view.addSubview(menuButton)
        
        menuButton.setImage(UIImage(named: "Add"), for: UIControlState())
        menuButton.addTarget(self, action: #selector(menuButtonAction), for: UIControlEvents.touchUpInside)
        
        self.view.layoutIfNeeded()
    }
    
    func menuButtonAction() {
        present(eventCreationNavCon!, animated: true, completion: nil)
    }
}
