//
//  Comment.swift
//  Production
//
//  Created by Garrett Fritz on 2/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper


@objcMembers
class CommentDescriptor: Object {
    
 
    dynamic var peekedComments = List<Comment>()
    dynamic var numMessages: Int = 0
    
}
