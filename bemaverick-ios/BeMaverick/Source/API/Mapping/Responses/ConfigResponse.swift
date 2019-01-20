//
//  UserDetailsResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ConfigResponse: Mappable {
    
    var config:      Config?
    
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        
        config       <- map["config"]
        
    }
    
}
