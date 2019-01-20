//
//  SearchResponses.swift
//  BeMaverick
//
//  Created by David McGraw on 12/6/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

struct SearchResponses: Mappable {
    
    var badgeId:                String?
    var count:                  Int?
    var offset:                 Int?
    
    var totalUserCount:         Int?
    var userIds:                [String]?
    
    var totalResponseCount:     Int?
    var responseIds:            [String]?
    
    var totalChallengeCount:    Int?
    var challengeIds:           [String]?
    
    var totalContentCount:      Int?
    var contentIds:             [String]?
    
    var objectIds:              [String]?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        
        badgeId             <- map["params.badgeId"]
        count               <- map["params.count"]
        offset              <- map["params.offset"]
        
        totalUserCount      <- map["totalUserCount"]
        userIds             <- map["userIds"]
        
        totalResponseCount  <- map["totalResponseCount"]
        responseIds         <- map["responseIds"]
        
        totalChallengeCount <- map["totalChallengeCount"]
        challengeIds        <- map["challengeIds"]
        
        totalContentCount   <- map["totalContentCount"]
        contentIds          <- map["contentIds"]
        
        objectIds           <- map["objectIds"]
        
    }
    
}
