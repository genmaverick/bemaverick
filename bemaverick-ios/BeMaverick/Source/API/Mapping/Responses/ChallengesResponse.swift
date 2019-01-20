//
//  ChallengesRequest.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ChallengesResponse: Mappable {
    
    var users:          [String: User]?
    var videos:         [String: Video]?
    var images:         [String: Image]?
  
    var badges:         [String: BadgeStats]?
    var challenges:     [String: Challenge]?
    var searchResults:  SearchResults?
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        
        users           <- map["users"]
        videos          <- map["videos"]
        badges          <- map["badges"]
        challenges      <- map["challenges"]
        images          <- map["images"]
        searchResults   <- map["site.searchResults"]
        
    }
    
}

