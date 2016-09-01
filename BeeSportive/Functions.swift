//
//  Functions.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 1.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation
import SJSegmentedScrollView
import FTIndicator

class Functions {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var segmentedViewController = SJSegmentedViewController()
    
    func getProfilePage(userID : String, vc : UIViewController) -> Void {
        let firstViewController = storyboard.instantiateViewControllerWithIdentifier("PastEventsViewController") as? PastEventsViewController
        firstViewController!.title = "Past Beevents"
        
        let headerViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileHeader") as? ProfileHeaderViewController
        
        let secondViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileStatsViewController") as? StatsViewController
        secondViewController!.title = "Stats"
        
        let thirdViewController = storyboard.instantiateViewControllerWithIdentifier("FavoriteSportsCollectionViewController") as? FavoriteSportsCollectionViewController
        thirdViewController!.title = "Favorite Sports"
        
        FTIndicator.showProgressWithmessage("Loading", userInteractionEnable: false)
        REF_USERS.child(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                let dict = NSDictionary(dictionary: snapshot.value as! [String : AnyObject])
                print(dict)
                
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
                
                self.segmentedViewController.selectedSegmentViewColor = UIColor.redColor()
                self.segmentedViewController.segmentViewHeight = 60.0
                self.segmentedViewController.segmentShadow = SJShadow.light()
                self.segmentedViewController.delegate = self
                
                headerViewController!.delegate = self.segmentedViewController
                
    
                vc.presentViewController(self.segmentedViewController, animated: true, completion: {
                    FTIndicator.dismissProgress()
                })
            }
        })
    }
}

extension Functions : SJSegmentedViewControllerDelegate {
    func didMoveToPage(controller: UIViewController, segment: UIButton?, index: Int) {
        
        if segmentedViewController.segments.count > 0 {
            
            let button = segmentedViewController.segments[index]
            button.setTitleColor(UIColor.orangeColor(), forState: .Selected)
        }
    }
}