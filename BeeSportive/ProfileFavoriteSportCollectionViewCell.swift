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
        image.layer.cornerRadius = ((screenSize.width/5.0)-4) * (7/20.0)
        image.layer.borderColor = UIColor.gray.cgColor
        image.layer.borderWidth = 1.0
    }
}
