//
//  UsersResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 1/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct UsersResponse: Mappable {
    
    var users:          [String: User]?
    var images:          [String: Image]?
    var searchResults:  SearchResults?
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        
        users           <- map["users"]
        images          <- map["images"]
        searchResults   <- map["site.searchResults"]
        
    }
    
}
