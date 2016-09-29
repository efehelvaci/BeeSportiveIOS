//
//  Comment.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 26.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    var id: String!
    var date: String!
    var comment: String!
    var height: CGFloat
    
    init(id: String, date: String, comment: String, height: CGFloat){
        self.id = id
        self.date = date
        self.comment = comment
        self.height = height
    }
}
