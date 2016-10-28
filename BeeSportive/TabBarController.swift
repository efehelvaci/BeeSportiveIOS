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
    let tabBarImageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    var eventCreationNavCon : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Selected item color at tab bar
        // Hex: 005B7F
        tabBar.tintColor = UIColor(red: 0/255, green: 94/255, blue: 127/255, alpha: 1)
        
        // View Controllers of tab bar
        let eventVC = storyboard!.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        let usersVC = storyboard!.instantiateViewController(withIdentifier: "UsersVC") as! UsersVC
        let eventCreateVC = storyboard!.instantiateViewController(withIdentifier: "EventFormViewController") as! EventFormViewController
        let notificationsVC = storyboard!.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        let profileVC = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        // Tab Bar Item Images
        eventVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Events"), tag: 1)
        usersVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Search"), tag: 2)
        notificationsVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "NotificationsRed")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal) , tag: 4)
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Avatar"), tag: 5)
        
        // Tab bar items stand centered at the bar
        eventVC.tabBarItem.imageInsets = tabBarImageInsets
        usersVC.tabBarItem.imageInsets = tabBarImageInsets
        notificationsVC.tabBarItem.imageInsets = tabBarImageInsets
        profileVC.tabBarItem.imageInsets = tabBarImageInsets
        
        // Navigation controller for view controllers (except the middle one)
        let navigationController1 = UINavigationController(rootViewController: eventVC)
        let navigationController2 = UINavigationController(rootViewController: usersVC)
        eventCreationNavCon = UINavigationController(rootViewController: eventCreateVC)
        let navigationController4 = UINavigationController(rootViewController: notificationsVC)
        let navigationController5 = UINavigationController(rootViewController: profileVC)
        
        // Navigation Bar Titles
        eventCreateVC.navigationItem.title = "Create Event"
        usersVC.navigationItem.title = "Search & Explore"
        notificationsVC.navigationItem.title = "Notifications"
        profileVC.navigationItem.title = "Profile"
        
        // Empty VC for middle item of the tab bar
        let viewController3 = UIViewController()
        viewController3.tabBarItem.isEnabled = false

        profileVC.sender = 0

        // Get profile
        currentUser.instance.delegate2 = profileVC
        
        setupMiddleButton()
        
        self.viewControllers = [navigationController1, navigationController2, viewController3, navigationController4, navigationController5]
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
