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
class Mention: Object, Mappable {
    
    dynamic var _id: String = ""
    dynamic var userId:   String?
    dynamic var userIdInt:   Int?
    dynamic var username:  String?

    func updateBasicData(_ mention: Mention) {
        
        userId = mention.userId
        username = mention.username
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(id: String) {
      
        self.init()
        self._id = id
        
    }
    
    func mapping(map: Map) {
        
        _id          <- map["_id"]
        userId        <- map["userId"]
        username       <- map["username"]
        userIdInt    <- map["userId"]
        
        if userId == nil, let user = userIdInt {
       
            userId = String(user)
            
        }
        
    }
  
    
    override var hashValue: Int {
        return _id.hashValue
    }
    
    static func ==(lhs: Mention, rhs: Mention) -> Bool {
        return lhs._id == rhs._id
    }
    
}

