//
//  ParticipantsCollectionViewCell.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 20.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ParticipantsCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var name: UILabel!
    
    var user : User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.adjustsFontSizeToFitWidth = true
        
        // Initialization code
    }
    
    func configureCell(user: User) {
        self.user = user
        
        imageView.isHidden = true
        name.text = user.displayName
        
        Alamofire.request(user.photoURL!).responseImage(completionHandler: { response in
            if let image = response.result.value {
                self.imageView.image = image
                self.imageView.isHidden = false
            }
        })
    }
}
