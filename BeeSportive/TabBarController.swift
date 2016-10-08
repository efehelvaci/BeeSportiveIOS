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
    
    let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    var eventCreationNavCon : UINavigationController?
    let tabBarImageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor(red: 249/255, green: 225/255, blue: 6/255, alpha: 1)

        let eventCreateVC = storyboard!.instantiateViewController(withIdentifier: "EventFormViewController")
        eventCreationNavCon = UINavigationController(rootViewController: eventCreateVC)
        eventCreateVC.navigationItem.title = "Create Event"
        eventCreationNavCon?.navigationBar.barTintColor = UIColor(red: 249/255, green: 225/255, blue: 6/255, alpha: 1)
        eventCreationNavCon?.navigationBar.tintColor = UIColor.gray
        eventCreationNavCon?.navigationBar.isTranslucent = false
        eventCreationNavCon?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Source Sans Pro", size: 24)!]
        
        let viewController1 = storyboard!.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        viewController1.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Events"), tag: 1)
        viewController1.tabBarItem.imageInsets = tabBarImageInsets
        let nav1 = UINavigationController(rootViewController: viewController1)
        nav1.navigationBar.barTintColor = UIColor.white
        
        let viewController2 = storyboard!.instantiateViewController(withIdentifier: "UsersVC") as! UsersVC
        viewController2.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Search"), tag: 2)
        viewController2.tabBarItem.imageInsets = tabBarImageInsets
        
        let viewController3 = UIViewController()
        viewController3.tabBarItem.isEnabled = false
        
        let viewController4 = storyboard!.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        viewController4.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Notifications"), tag: 4)
        viewController4.tabBarItem.imageInsets = tabBarImageInsets
        
        let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        viewController5.sender = 0
        viewController5.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Avatar"), tag: 5)
        viewController5.tabBarItem.imageInsets = tabBarImageInsets
        
        setupMiddleButton()
        
        self.viewControllers = [nav1, viewController2, viewController3, viewController4, viewController5]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMiddleButton() {
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height - 8
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
