//
//  RewardResponse.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct RewardResponse : Mappable {
    
    var data :    [Reward]?
    
    public init?(map: Map) {
        
        
    }
    
    mutating public func mapping(map: Map) {
        
        data            <- map["data"]
        
    }
    
}
