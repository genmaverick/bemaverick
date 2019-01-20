//
//  AuthorizationResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 9/25/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct AuthorizationResponse: Mappable {
    
    var accessToken:    String?
    var refreshToken:   String?
    var userId:         String?

    var coppaStatus:    String?
    var coppaMessage:   String?
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        
        accessToken      <- map["access_token"]
        refreshToken     <- map["refresh_token"]
        userId           <- map["user_id"]
        coppaStatus      <- map["coppa.status"]
        coppaMessage     <- map["coppa.message"]
        
    }
    
}

