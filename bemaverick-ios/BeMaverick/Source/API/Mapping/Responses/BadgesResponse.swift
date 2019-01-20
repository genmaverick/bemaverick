//
//  CommentResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 1/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct BadgesResponse: Mappable {
    
    var badges :     [String:MBadge]?
    var sortOrder : [String]?
    
    public init?(map: Map) {
        
        
    }
    
    mutating public func mapping(map: Map) {
        
        badges               <- map["badges"]
        sortOrder                <- map["site.searchResults.badges.badgeIds"]
        
    }
    
}
