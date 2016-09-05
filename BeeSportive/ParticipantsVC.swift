//
//  ParticipantsVC.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 05/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class ParticipantsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var eventID: String!
    var participants = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        REF_EVENTS.child(eventID).child("participants").observeEventType(.Value, withBlock: { snapshot in
            self.participants.removeAll()
        })
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ParticipantCell", forIndexPath: indexPath) as? ParticipantCell else { return UICollectionViewCell() }
        cell.configureCell(participants[indexPath.row])
        return cell
    }

}
