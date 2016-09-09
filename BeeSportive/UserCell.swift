//
//  UserCell.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 06/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FTIndicator
import Haneke

class UserCell: UICollectionViewCell {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var img: UIImageView!

    func configureCell(user: User) {
        self.hidden = true
        displayName.text = user.displayName
        if let urlStr = user.photoURL {
            let imgURL = NSURL(string: urlStr)!
            self.img.hnk_setImageFromURL(imgURL, placeholder: UIImage(), format: nil, failure: nil, success: { (image) in
                self.img.layer.masksToBounds = true
                self.img.layer.cornerRadius = self.img.frame.width / 2.0
                self.img.image = image
                FTIndicator.dismissProgress()
            })
        }; self.hidden = false
    }

}
