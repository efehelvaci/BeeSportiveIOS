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
import SJSegmentedScrollView

class TabBarController: UITabBarController {
    
    let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 72))
    var segmentedViewController = SJSegmentedViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor(red: 249/255, green: 225/255, blue: 6/255, alpha: 1)
        
        getProfilePage((FIRAuth.auth()?.currentUser!.uid)!)
        
        let viewController1 = storyboard!.instantiateViewControllerWithIdentifier("EventViewController") as! EventViewController
        viewController1.tabBarItem = UITabBarItem(title: "Events", image: UIImage(named: "Events"), tag: 1)
        let nav1 = UINavigationController(rootViewController: viewController1)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = nav1.navigationBar.bounds
        gradientLayer.frame.size.height += 20
        gradientLayer.colors = [UIColor.yellowColor(),UIColor.whiteColor()].map{$0.CGColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set the UIImage as background property
        nav1.navigationBar.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
        
        let viewController2 = storyboard!.instantiateViewControllerWithIdentifier("UsersVC") as! UsersVC
        viewController2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "SearchPeople"), tag: 2)
        
        let viewController3 = UIViewController()
        
        let viewController4 = UIViewController()
        viewController4.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(named: "Notifications"), tag: 4)
        
        segmentedViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Avatar"), tag: 5)
        
        setupMiddleButton()
        
        self.viewControllers = [nav1, viewController2, viewController3, viewController4, segmentedViewController]
        // Do any additional setup after loading the view.
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
        
//        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        self.view.addSubview(menuButton)
        
        menuButton.setImage(UIImage(named: "Add"), forState: UIControlState.Normal)
        menuButton.addTarget(self, action: #selector(menuButtonAction), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.layoutIfNeeded()
    }
    
    func menuButtonAction() {
        self.presentViewController(storyboard!.instantiateViewControllerWithIdentifier("EventFormViewController"), animated: true, completion: nil)
    }
    
    func getProfilePage(userID : String) -> Void {
        let firstViewController = storyboard!.instantiateViewControllerWithIdentifier("PastEventsViewController") as? PastEventsViewController
        firstViewController!.title = "Past Beevents"
        
        let headerViewController = storyboard!.instantiateViewControllerWithIdentifier("ProfileHeader") as? ProfileHeaderViewController
        headerViewController?.sender = 0
        
        let secondViewController = storyboard!.instantiateViewControllerWithIdentifier("ProfileStatsViewController") as? StatsViewController
        secondViewController!.title = "Stats"
        
        let thirdViewController = storyboard!.instantiateViewControllerWithIdentifier("FavoriteSportsCollectionViewController") as? FavoriteSportsCollectionViewController
        thirdViewController!.title = "Favorite Sports"
        
        REF_USERS.child(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                let dict = NSDictionary(dictionary: snapshot.value as! [String : AnyObject])
                
                let displayName = dict.valueForKey("displayName") as! String
                let email = dict.valueForKey("email") as! String
                let photoURL = dict.valueForKey("photoURL") as! String
                let id = dict.valueForKey("id") as! String
                
                let user = User(displayName: displayName, photoURL: photoURL, email: email, id: id)
                
                firstViewController!.user = user
                secondViewController!.user = user
                thirdViewController!.user = user
                headerViewController!.user = user
                
                self.segmentedViewController = SJSegmentedViewController()
                
                self.segmentedViewController.headerViewController = headerViewController!
                self.segmentedViewController.segmentControllers = [firstViewController!,
                    secondViewController!,
                    thirdViewController!]
                self.segmentedViewController.headerViewHeight = 200
                
                self.segmentedViewController.selectedSegmentViewColor = UIColor.orangeColor()
                self.segmentedViewController.segmentViewHeight = 60.0
                self.segmentedViewController.segmentShadow = SJShadow.light()
                self.segmentedViewController.delegate = self
                
                headerViewController!.delegate = self.segmentedViewController
                self.segmentedViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Avatar"), tag: 5)
                
                self.viewControllers?.removeAtIndex(4)
                self.viewControllers?.insert(self.segmentedViewController, atIndex: 4)
            }
        })
    }
}

extension TabBarController : SJSegmentedViewControllerDelegate {
    func didMoveToPage(controller: UIViewController, segment: UIButton?, index: Int) {
        
        if segmentedViewController.segments.count > 0 {
            
            let button = segmentedViewController.segments[index]
            button.setTitleColor(UIColor.orangeColor(), forState: .Selected)
        }
    }
}