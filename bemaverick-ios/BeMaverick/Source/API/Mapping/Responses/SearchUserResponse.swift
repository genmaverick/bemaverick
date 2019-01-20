//
//  Badge.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

struct SearchUserResponse: Mappable {
    
    var searchUsers:        [SearchUser]?
 
    init?(map: Map) { }
    
    
    mutating func mapping(map: Map) {
        
        searchUsers         <- map
      
        
    }
    
}
