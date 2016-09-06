//
//  UserCell.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 06/09/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class UserCell: UICollectionViewCell {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var img: UIImageView!

    func configureCell(user: User) {
        displayName.text = user.displayName
        if let urlStr = user.photoURL {
            let imgURL = NSURL(string: urlStr)!
            Alamofire.request(.GET, imgURL).responseData{ response in
                if let image = response.result.value {
                    self.img.layer.masksToBounds = true
                    //self.img.layer.cornerRadius = self.img.frame.width / 2.0
                    self.img.image = UIImage(data: image)
                }
            }
        }
    }

}
