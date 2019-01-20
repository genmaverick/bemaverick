//
//  Project.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/11/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

@objcMembers
class Level: Object, Mappable {
    
    dynamic var levelId = ""
    dynamic var levelNumber : Int = 0
    dynamic var pointsRequired : Int = 0
    dynamic var color : String? = "#980000"
    dynamic var name : String? = "Beginner"
    
    //still needed from API
    
     dynamic var levelSummary:  String? = "You’re easily going to reach the next level, no problem."
    dynamic var levelProgressionSuggestion:  String? = "• Give more badges\n• Create more challenge\n• Respond to more challenges\n• Post more comments\n• Mention your friend\n• Create more video responses"
    dynamic var levelRewards:  String? = "• Unlock special sticker pack\n• Ability to create video challenges"
    
    
    
    override static func primaryKey() -> String? {
        
        return "levelId"
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    func update(level: Level) {
        
        
        levelNumber = level.levelNumber
        pointsRequired = level.pointsRequired
        color = level.color
        name = level.name
        levelProgressionSuggestion = level.levelProgressionSuggestion
        levelRewards = level.levelRewards
        levelSummary = level.levelSummary
        
    }
    
    convenience init(levelId : String) {
        
        self.init()
        self.levelId = levelId
        
    }
    
    func mapping(map: Map) {
        
        levelId <- map["_id"]
        levelNumber  <- map["levelNumber"]
        pointsRequired <- map["pointsRequired"]
        color <- map["color"]
        name <- map["name"]
        
    }
    
}
