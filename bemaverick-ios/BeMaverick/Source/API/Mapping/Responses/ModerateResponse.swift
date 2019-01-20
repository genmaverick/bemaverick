//
//  ModerateResponse.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


import Foundation
import ObjectMapper

public struct ModerateResponse: Mappable {
 
    var action :     String?
    var text :      String?
    
    
    public init?(map: Map) {
        
        
    }
    
    mutating public func mapping(map: Map) {
        
        action            <- map["action"]
        text              <- map["text"]
}
    
}
