//
//  EventCollectionViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 17.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var dateDay: UILabel!
    @IBOutlet var dateMonth: UILabel!
    @IBOutlet var creatorName: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var creatorImage: UIImageView!
    @IBOutlet var branchName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func offset(offset: CGPoint) {
        backgroundImage.frame = CGRectOffset(self.backgroundImage.bounds, offset.x, offset.y)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    
}
