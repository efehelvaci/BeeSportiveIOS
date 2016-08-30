//
//  ChannelCell.swift
//  Chatmates
//
//  Created by Doruk Gezici on 04/07/16.
//  Copyright © 2016 Doruk Gezici. All rights reserved.
//

import UIKit
import Firebase
import Async
import Alamofire
import AlamofireImage

class ChannelCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var sender: UILabel!

    func configureCell(channelID: String) {
        REF_EVENTS.child(channelID).observeEventType(.Value, withBlock: { snapshot in
            if let title = snapshot.childSnapshotForPath("name").value as? String {
                self.title.text = title
            }
            if let branch = snapshot.childSnapshotForPath("branch").value as? String {
                self.backgroundView = UIImageView(image: UIImage(named: branch))
            }
            if let imgURLstr = snapshot.childSnapshotForPath("creatorImageURL").value as? String {
                let imgURL = NSURL(string: imgURLstr)!
                Async.background {
                    Alamofire.request(.GET, imgURL).responseData{ response in
                        if let image = response.result.value {
                            self.img.image = UIImage(data: image)
                        }
                    }
                }
            }
        })
    }

}
