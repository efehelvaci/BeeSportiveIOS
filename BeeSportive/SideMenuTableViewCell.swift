//
//  SideMenuTableViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 25.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {


    @IBOutlet var sideBarIcon: UIImageView!
    @IBOutlet var sideBarLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
