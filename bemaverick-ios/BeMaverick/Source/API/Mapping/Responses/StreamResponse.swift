//
//  UserDetailsResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct StreamResponse: Mappable {
    
    var streams     :      [String : Stream]?
    var order       :       [String]?
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        
        streams       <- map["streams"]
        order         <- map["site.searchResults.streams.streamIds"]
    }
    
}
