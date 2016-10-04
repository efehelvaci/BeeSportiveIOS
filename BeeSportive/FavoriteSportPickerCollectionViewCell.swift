//
//  FavoriteSportPickerCollectionViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 4.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class FavoriteSportPickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var branchImage: UIImageView!
    
    @IBOutlet var branchName: UILabel!
    
    @IBOutlet var yellowCurtainView: UIView!
    
    override func awakeFromNib() {
        layoutIfNeeded()
        
        branchImage.layer.cornerRadius = (screenSize.width/5 - 8) / 2.0
        yellowCurtainView.layer.cornerRadius = screenSize.width/10 - 8/5.0
        
        branchImage.clipsToBounds = true
        yellowCurtainView.clipsToBounds = true
    }
    
}
