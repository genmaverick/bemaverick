//
//  Stat.swift
//  BeMaverick
//
//  Created by David McGraw on 10/1/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class Stat: Object, Mappable {
    
    dynamic var numReceivedBadges = 0
    dynamic var numGivenBadges = 0
    dynamic var numFollowingUsers = 0
    dynamic var numFollowerUsers = 0
    dynamic var number = 0
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        numReceivedBadges       <- map["numReceivedBadges"]
        numGivenBadges          <- map["numGivenBadges"]
        numFollowingUsers       <- map["numFollowingUsers"]
        numFollowerUsers        <- map["numFollowerUsers"]
        
    }
    
}
