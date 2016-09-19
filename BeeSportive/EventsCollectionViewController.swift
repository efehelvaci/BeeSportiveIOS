//
//  EventsCollectionViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 19.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "eventCell"

class EventsCollectionViewController: UICollectionViewController {
    
    var branchName : String?
    var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle: nil)
        
        self.collectionView!.registerNib(nibName, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
        
        // Filling cell
        cell.backgroundImage.image = UIImage(named: events[indexPath.row].branch)
        cell.creatorName.text = events[indexPath.row].creatorName
        cell.dateDay.text = events[indexPath.row].day
        cell.dateMonth.text =  months[Int(events[indexPath.row].month)! - 1]
        cell.location.text = events[indexPath.row].location
        cell.location.adjustsFontSizeToFitWidth = true
        cell.time.text = events[indexPath.row].time
        cell.branchName.text = (events[indexPath.row].branch).uppercaseString
        
        Alamofire.request(.GET, (self.events[indexPath.row].creatorImageURL)).responseData{ response in
            if let image = response.result.value {
                cell.creatorImage.layer.masksToBounds = true
                cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                cell.creatorImage.image = UIImage(data: image)
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let eventDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
        
        eventDetailVC.event = events[indexPath.row]
        self.presentViewController(eventDetailVC, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenSize.width, 180)
    }


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
