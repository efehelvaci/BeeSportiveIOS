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
        
        self.collectionView!.register(nibName, forCellWithReuseIdentifier: reuseIdentifier)
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        
        // Filling cell
        cell.date.text = events[(indexPath as NSIndexPath).row].day + " " + months[Int(events[(indexPath as NSIndexPath).row].month)! - 1] + ", " + events[(indexPath as NSIndexPath).row].time
        cell.backgroundImage.image = UIImage(named: events[(indexPath as NSIndexPath).row].branch)
        cell.creatorName.text = events[(indexPath as NSIndexPath).row].creatorName
        cell.location.text = events[(indexPath as NSIndexPath).row].location
        cell.location.adjustsFontSizeToFitWidth = true
        cell.branchName.text = (events[(indexPath as NSIndexPath).row].branch).uppercased()
        
        Alamofire.request(self.events[(indexPath as NSIndexPath).row].creatorImageURL).responseImage(completionHandler: { response in
            if let image = response.result.value {
                cell.creatorImage.layer.masksToBounds = true
                cell.creatorImage.layer.cornerRadius = cell.creatorImage.frame.width / 2.0
                cell.creatorImage.image = image            }
        })
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        
        eventDetailVC.event = events[(indexPath as NSIndexPath).row]
        self.present(eventDetailVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenSize.width, height: 180)
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
