//
//  ProfileCommentTableViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 26.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class ProfileCommentTableViewCell: UITableViewCell {
    
    @IBOutlet var userImage: UIImageView!
    
    @IBOutlet var name: UILabel!

    @IBOutlet var comment: UILabel!
    
    @IBOutlet var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
