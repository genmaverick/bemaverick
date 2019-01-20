//
//  RewardsProgress.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class RewardsProgress: Object, Mappable {
    
    dynamic var reward : Reward?
    dynamic var completed : Bool = false
    dynamic var completedDate : String?
    dynamic var levelNumber : Int = 0
    dynamic var rewardKey : String?
    dynamic var rewardName : String?
    
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
  
    func mapping(map: Map) {
        
        reward              <- map["reward"]
        completed           <- map["completed"]
        completedDate       <- map["completedDate"]
        levelNumber         <- map["levelNumber"]
        rewardKey           <- map["rewardKey"]
        rewardName          <- map["rewardName"]
        
    }
    
}

