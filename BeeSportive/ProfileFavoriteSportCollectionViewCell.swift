//
//  ProfileFavoriteSportCollectionViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 26.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class ProfileFavoriteSportCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        image.layer.masksToBounds = true
        image.layer.cornerRadius = image.frame.width/2.0
    }
}
