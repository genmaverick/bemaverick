//
//  CommentResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 1/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct CommentResponse: Mappable {
    
    var count :     Int?
    var data : [Comment]?
    var body : String?
    var _id : String?
    var created : String?
    var mentionsArray : [Mention]?
    
    public init?(map: Map) {
        
        
    }
    
    mutating public func mapping(map: Map) {
        
        count               <- map["meta.count"]
        data                <- map["data"]
        body                <- map["body"]
        _id                 <- map["_id"]
        mentionsArray       <- map["meta.mentions"]
        created             <- map["created"]
        
    }
    
}
