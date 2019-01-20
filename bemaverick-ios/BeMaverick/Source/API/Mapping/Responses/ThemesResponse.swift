//
//  ThemesResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 1/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ThemesResponse: Mappable {
    
    var count :     Int?
    var themes :      [Theme]?
    var _id : String?
    var sortOrder : [String]?
    
    
    public init?(map: Map) {
        
        
    }
    
    mutating public func mapping(map: Map) {
        
        count               <- map["meta.count"]
        themes              <- map["data"]
//        sortOrder           <- map["meta.sort.sortOrder"]
    }
    
}
