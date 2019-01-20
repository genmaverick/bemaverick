//
//  ResponsesResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ResponsesResponse: Mappable {
    
    var users:          [String: User]?
    var videos:         [String: Video]?
    var images:         [String: Image]?
    var badges:         [String: BadgeStats]?
    var challenges:     [String: Challenge]?
    var responses:      [String: Response]?
    var multiContentOrder:      [MultiContentObject]?
    var searchResults:  SearchResults?
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        
        users           <- map["users"]
        videos          <- map["videos"]
        images          <- map["images"]
        challenges      <- map["challenges"]
        responses       <- map["responses"]
        badges          <- map["badges"]
        searchResults   <- map["site.searchResults"]
        multiContentOrder <- map["searchResults.myFeed.data"]
        
    }
    
}
