//
//  ProjectProgress.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class LevelProgress: Object, Mappable {
    
    dynamic var level : Level?
    dynamic var levelNumber : Int = 0
    dynamic var pointsCompleted : Int = 0
    dynamic var completedDate : String?
    dynamic var progress : Float = 0.0
    dynamic var completed : Bool = false
    
   
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
  
    func mapping(map: Map) {
        
        level                <- map["level"]
        pointsCompleted         <- map["pointsCompleted"]
        completedDate                <- map["completedDate"]
        progress               <- map["progress"]
       
        completed <- map["completed"]
        levelNumber <- map["levelNumber"]
        
    }
    
}

