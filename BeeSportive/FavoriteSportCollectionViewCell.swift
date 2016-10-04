//
//  FavoriteSportCollectionViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 30.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class FavoriteSportCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var favSportImage: UIImageView!
    @IBOutlet var favSportName: UILabel!
    
    override func awakeFromNib() {
        favSportName.adjustsFontSizeToFitWidth = true
        
        layoutIfNeeded()
        clipsToBounds = false
    }
}
