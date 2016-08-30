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
    
    let databaseRef = FIRDatabase.database().reference()
    var segmentedViewController = SJSegmentedViewController()

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

    }
    
    internal func pushProfilePage(userID: String) {
        FTIndicator.showProgressWithmessage("Loading", userInteractionEnable: false)
        databaseRef.child("users").child(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                let dict = NSDictionary(dictionary: snapshot.value as! [String : AnyObject])
                print(dict)

                let displayName = dict.valueForKey("displayName") as! String
                let email = dict.valueForKey("email") as! String
                let photoURL = dict.valueForKey("photoURL") as! String
                let id = dict.valueForKey("id") as! String
                
                let user = User(displayName: displayName, photoURL: photoURL, email: email, id: id)
                
                let viewController = self.getSJSegmentedViewController(user)
                
                if viewController != nil {
                    self.presentViewController(viewController!, animated: true, completion: {
                        FTIndicator.dismissProgress()
                    })
                }
            }
        })
    }
    
    func getSJSegmentedViewController(user: User) -> SJSegmentedViewController? {
        
        segmentedViewController = SJSegmentedViewController()
        
        if let storyboard = self.storyboard {
            
            let headerViewController = storyboard
                .instantiateViewControllerWithIdentifier("ProfileHeader") as! ProfileHeaderViewController
            headerViewController.user = user
            
            let firstViewController = storyboard
                .instantiateViewControllerWithIdentifier("PastEventsViewController") as! PastEventsViewController
            firstViewController.title = "Past Beevents"
            firstViewController.user = user
            
            let secondViewController = storyboard
                .instantiateViewControllerWithIdentifier("ProfileStatsViewController") as! StatsViewController
            secondViewController.title = "Stats"
            secondViewController.user = user
            
            let thirdViewController = storyboard
                .instantiateViewControllerWithIdentifier("FavoriteSportsCollectionViewController") as! FavoriteSportsCollectionViewController
            thirdViewController.title = "Favorite Sports"
            thirdViewController.user = user
            
            segmentedViewController.headerViewController = headerViewController
            segmentedViewController.segmentControllers = [firstViewController,
                                                          secondViewController,
                                                          thirdViewController]
            segmentedViewController.headerViewHeight = 200
            
            segmentedViewController.selectedSegmentViewColor = UIColor.redColor()
            segmentedViewController.segmentViewHeight = 60.0
            segmentedViewController.segmentShadow = SJShadow.light()
            segmentedViewController.delegate = self
            
            headerViewController.delegate = segmentedViewController
            
            return segmentedViewController
        }
        
        return nil
    }
    
    func getUserFromID(userID: String){
        
    }
}

extension MainNavigationController: SJSegmentedViewControllerDelegate {
    
    func didMoveToPage(controller: UIViewController, segment: UIButton?, index: Int) {
        
        if segmentedViewController.segments.count > 0 {
            
            let button = segmentedViewController.segments[index]
            button.setTitleColor(UIColor.orangeColor(), forState: .Selected)
        }
    }
}
