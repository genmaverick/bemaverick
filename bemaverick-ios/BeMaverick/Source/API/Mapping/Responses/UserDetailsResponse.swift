//
//  UserDetailsResponse.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

public struct UserDetailsResponse: Mappable {
    
    var users:      [String: User]?
    var videos:     [String: Video]?
    var images:     [String: Image]?
    
    var badges:     [String: BadgeStats]?
    var challenges: [String: Challenge]?
    var responses:  [String: Response]?
    var loginUser:  User?
    
    public init?(map: Map) { }
    
    mutating public func mapping(map: Map) {
        
        users       <- map["users"]
        videos      <- map["videos"]
        images      <- map["images"]
        
        badges      <- map["badges"]
        challenges  <- map["challenges"]
        responses   <- map["responses"]
        loginUser   <- map["loginUser"]
        
    }
    
}
