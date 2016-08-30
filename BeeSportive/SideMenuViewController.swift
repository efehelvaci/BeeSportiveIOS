//
//  SideMenuViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 23.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import REFrostedViewController
import Firebase
import FirebaseAuth
import Alamofire
import AlamofireImage
import Async
import SJSegmentedScrollView

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    let segmentedViewController = SJSegmentedViewController()
    let tableItems : [String] = ["Profile", "Settings"]
    let tableItemsIcons : [UIImage] = [UIImage(named: "Profile3")!, UIImage(named: "Settings")!]
    var whoSendIt : Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableHeader()
        
        // Table view cell register nib
        let nibName = UINib(nibName: "SideMenuTableViewCell", bundle:nil)
        tableView.registerNib(nibName, forCellReuseIdentifier: "sideBarItem")
    }
    
    //
    // TableView delegate methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sideBarItem", forIndexPath: indexPath) as! SideMenuTableViewCell
    
        cell.sideBarLabel.text = tableItems[indexPath.row]
        cell.sideBarIcon.image = tableItemsIcons[indexPath.row]
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mainNavigationController = frostedViewController.contentViewController as! MainNavigationController
        let viewController = getSJSegmentedViewController()
        
        switch indexPath.row {
        case 0:
            if viewController != nil {
                mainNavigationController.presentViewController(viewController!, animated: true, completion: nil)
            }
            break
        default:
            print("Switch default")
        }
        
        frostedViewController.hideMenuViewController()
    }
    
    //
    // Table view header with profile image and name
    func setTableHeader() {
        let headerView = UIView(frame: CGRectMake(0, 0, 0, 184))
        let imageView = UIImageView(frame: CGRectMake(0, 30, 100, 100))
        let label = UILabel(frame: CGRectMake(0, 140, 0, 24))
        
        headerView.backgroundColor = UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 0.8)
        
        Async.background{
            Alamofire.request(.GET, (FIRAuth.auth()?.currentUser?.photoURL)!).responseData{ response in
                if let image = response.result.value {
                    imageView.image = UIImage(data: image)
                }
            }
        }
        imageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 50.0
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 3.0
        imageView.layer.rasterizationScale = UIScreen.mainScreen().scale
        imageView.layer.shouldRasterize = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clearColor()
        
        label.text = FIRAuth.auth()?.currentUser?.displayName
        label.font = UIFont(name: "HelveticaNeue", size: 21)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        
        headerView.addSubview(imageView)
        headerView.addSubview(label)
        
        self.tableView.tableHeaderView = headerView
    }
    
    func getSJSegmentedViewController() -> SJSegmentedViewController? {
        
        if let storyboard = self.storyboard {
            
            let headerViewController = storyboard
                .instantiateViewControllerWithIdentifier("ProfileHeader") as! ProfileHeaderViewController
            
            let firstViewController = storyboard
                .instantiateViewControllerWithIdentifier("PastEventsViewController")
            firstViewController.title = "Past Beevents"
            
            let secondViewController = storyboard
                .instantiateViewControllerWithIdentifier("ProfileStatsViewController")
            secondViewController.title = "Stats"
            
            let thirdViewController = storyboard
                .instantiateViewControllerWithIdentifier("FavoriteSportsCollectionViewController")
            thirdViewController.title = "Favorite Sports"
            
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
}

extension SideMenuViewController: SJSegmentedViewControllerDelegate {
    
    func didMoveToPage(controller: UIViewController, segment: UIButton?, index: Int) {
        
        if segmentedViewController.segments.count > 0 {
            
            let button = segmentedViewController.segments[index]
            button.setTitleColor(UIColor.orangeColor(), forState: .Selected)
        }
    }
}
