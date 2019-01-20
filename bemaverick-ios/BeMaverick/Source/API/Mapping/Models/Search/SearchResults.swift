//
//  SearchResults.swift
//  BeMaverick
//
//  Created by David McGraw on 11/30/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

struct SearchResults: Mappable {
    
    var users:              SearchResponses?
    var challenges:         SearchResponses?
    var responses:          SearchResponses?
    var badgeUsers:         SearchResponses?
    var badgedResponses:    SearchResponses?
    var responseFeed:       SearchResponses?
    var maverickStream:     SearchResponses?
    var contents:           SearchResponses?
    var challengeStream:           SearchResponses?
    
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        
        users               <- map["users"]
        challenges          <- map["challenges"]
        responses           <- map["responses"]
        badgeUsers          <- map["badgeUsers"]
        badgedResponses     <- map["badgedResponses"]
        responseFeed        <- map["responseFeed"]
        maverickStream      <- map["maverickStream"]
        contents            <- map["contents"]
        challengeStream     <- map["challengeStream"]
        
    }
    
}
