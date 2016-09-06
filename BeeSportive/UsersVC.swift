//
//  UsersVC.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 06/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase

class UsersVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var users = [User]()

    @IBAction func dismissVC(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "UserCell", bundle:nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "userCell")
        REF_USERS.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let user = User(snapshot: snapshot)
            self.users.append(user)
            self.collectionView.reloadData()
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCell", forIndexPath: indexPath) as? UserCell {
            cell.configureCell(users[indexPath.row])
            return cell
        } else { return UICollectionViewCell() }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenSize.width/2.5, 210)
    }

}
