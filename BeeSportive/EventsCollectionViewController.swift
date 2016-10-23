//
//  EventsCollectionViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 19.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

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
        cell.configureCell(event: events[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        
        eventDetailVC.event = events[(indexPath as NSIndexPath).row]
        self.present(eventDetailVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenSize.width, height: 144)
    }

}
