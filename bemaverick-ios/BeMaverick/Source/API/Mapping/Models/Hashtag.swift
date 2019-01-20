//
//  Tag.swift
//  BeMaverick
//
//  Created by David McGraw on 10/7/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
public class Hashtag: Object, Mappable {

    var count: Int?
    var name: String?
    
    required convenience public init?(map: Map) {
        
        self.init()
        
    }
    
    public func mapping(map: Map) {
        
        count   <- map["count"]
        name    <- map["name"]
    
    }
    
    convenience init(tagName: String) {
        
        self.init()
        self.name = tagName
        
    }
    
}
    


