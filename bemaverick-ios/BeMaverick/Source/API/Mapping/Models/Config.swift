//
//  User.swift
//  BeMaverick
//
//  Created by David McGraw on 9/18/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

struct Config: Mappable {
    
  
    var profileCoverPresetImageIds:   [String]?
    var profileCoverPresetImageUrls:  [String: [String:String]]?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        
        profileCoverPresetImageIds      <- map["profileCoverPresetImageIds"]
        profileCoverPresetImageUrls     <- map["profileCoverPresetImageUrls"]
        
    }
        
}

