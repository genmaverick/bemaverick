//
//  Badge.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper

struct SearchUser: Mappable {
    
    var user_id:        String?
    var username:           String?
    var first_name:    String?
    var last_name:       String?
    var email_address:  String?
    var phone_number:  String?
    var user_type:   String?
    var profile_image : Image?
    var isVerified : Bool?

    var identifier:     Int {
        
        get {
            if let id = user_id, let value = Int(id) {
                return value
            }
            return hashValue
        }
        
    }
    
    init?(map: Map) { }

    mutating func mapping(map: Map) {
        
        user_id             <- map["user_id"]
        username            <- map["username"]
        first_name          <- map["first_name"]
        last_name           <- map["last_name"]
        email_address       <- map["email_address"]
        user_type           <- map["user_type"]
        profile_image       <- map["profile_image"]
        phone_number        <- map["phone_number"]
        isVerified          <- map["isVerified"]
        
    }
    
}

extension SearchUser: Hashable {
    
    var hashValue: Int {
        return "\(user_id ?? "NONE") \(username ?? "NONE")".hashValue
    }
    
    static func ==(lhs: SearchUser, rhs: SearchUser) -> Bool {
        return lhs.user_id == rhs.user_id
    }
    
}
