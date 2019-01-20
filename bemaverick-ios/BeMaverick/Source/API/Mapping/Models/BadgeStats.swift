//
//  MaverickModel.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class BadgeStats: Object, Mappable {
    
    
   dynamic var badgeId:        String = ""
   dynamic var name:           String?
   dynamic var numReceived:    Int = 0
   dynamic var numGiven:       Int = 0
    
    func setValues(badge: BadgeStats) {
        
        badgeId = badge.badgeId
        numReceived = badge.numReceived
        name = badge.name
        numGiven = badge.numGiven
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(badgeTypeId: String) {
        
        self.init()
        self.badgeId = badgeTypeId
        
        
    }
    
    func mapping(map: Map) {
        
        badgeId         <- map["badgeId"]
        name            <- map["name"]
        numReceived     <- map["numReceived"]
        numGiven        <- map["numGiven"]
        
    }
    
}
